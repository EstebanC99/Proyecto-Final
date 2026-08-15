using CareWell.Logger;
using Microsoft.Extensions.AI;
using System.Net.Http.Json;
using System.Runtime.CompilerServices;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.Json.Serialization;

namespace CareWell.DocumentIntelligence
{
    /// <summary>
    /// Cliente mínimo de IChatClient para Gemini vía Vertex AI / Agent Platform (publisher models),
    /// sin pasar por ningún endpoint compatible con OpenAI ni por paquetes de terceros. Soporta VertexAI y AIStudio, 
    /// que comparten el mismo formato REST y difieren sólo en la URL base; 
    /// Habla directamente el formato REST de Gemini.
    /// </summary>
    internal sealed class GeminiChatClient : IChatClient
    {
        private readonly HttpClient httpClient;
        private readonly string baseUrl;
        private readonly string apiKey;
        private readonly string model;
        private readonly bool enviarResponseSchema;
        private readonly IRegistradorLogServicioExterno registradorLogServicioExterno;
        
        private static readonly JsonSerializerOptions OpcionesSerializacion = new()
        {
            DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
        };

        public GeminiChatClient(string baseUrl, string apiKey, string model, TimeSpan timeout, bool enviarResponseSchema, IRegistradorLogServicioExterno registradorLogServicioExterno)
        {
            this.baseUrl = baseUrl;
            this.apiKey = apiKey;
            this.model = model;
            this.httpClient = new HttpClient { Timeout = timeout };
            this.enviarResponseSchema = enviarResponseSchema;
            this.registradorLogServicioExterno = registradorLogServicioExterno;
        }

        public async Task<ChatResponse> GetResponseAsync(
            IEnumerable<ChatMessage> messages,
            ChatOptions? options = null,
            CancellationToken cancellationToken = default)
        {
            var request = ConstruirRequest(messages, options, this.enviarResponseSchema);
            var requestJson = JsonSerializer.Serialize(request, OpcionesSerializacion);
            var url = $"{this.baseUrl}/{model}:generateContent";

            using var httpRequest = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = JsonContent.Create(request, options: OpcionesSerializacion)
            };

            httpRequest.Headers.Add("x-goog-api-key", this.apiKey);

            using var httpResponse = await this.httpClient.SendAsync(httpRequest, cancellationToken);
            var cuerpoRespuesta = await httpResponse.Content.ReadAsStringAsync(cancellationToken);

            this.registradorLogServicioExterno.Registrar("Gemini", requestJson, cuerpoRespuesta);

            if (!httpResponse.IsSuccessStatusCode)
            {
                throw new HttpRequestException(
                    $"Gemini respondió {(int)httpResponse.StatusCode} {httpResponse.StatusCode}: {cuerpoRespuesta}");
            }

            var geminiResponse = JsonSerializer.Deserialize<GeminiResponse>(cuerpoRespuesta);
            var texto = geminiResponse?.Candidates?
                .FirstOrDefault()?.Content?.Parts?
                .FirstOrDefault(p => p.Text is not null)?.Text
                ?? string.Empty;

            return new ChatResponse(new ChatMessage(ChatRole.Assistant, texto));
        }

        public async IAsyncEnumerable<ChatResponseUpdate> GetStreamingResponseAsync(
            IEnumerable<ChatMessage> messages,
            ChatOptions? options = null,
            [EnumeratorCancellation] CancellationToken cancellationToken = default)
        {
            var response = await this.GetResponseAsync(messages, options, cancellationToken);
            yield return new ChatResponseUpdate(ChatRole.Assistant, response.Text);
        }

        public object? GetService(Type serviceType, object? serviceKey = null) =>
            serviceKey is null && serviceType.IsInstanceOfType(this) ? this : null;

        public void Dispose() => this.httpClient.Dispose();

        private static GeminiRequest ConstruirRequest(IEnumerable<ChatMessage> messages, ChatOptions? options, bool enviarResponseSchema)
        {
            List<GeminiPart> systemParts = [];
            List<GeminiContent> contents = [];

            foreach (var message in messages)
            {
                var parts = ConstruirParts(message);

                if (message.Role == ChatRole.System)
                    systemParts.AddRange(parts);
                else
                    contents.Add(new GeminiContent("user", parts));
            }

            GeminiGenerationConfig? generationConfig = null;

            if (options?.ResponseFormat is ChatResponseFormatJson formatoJson)
            {
                var responseJsonSchema = enviarResponseSchema && formatoJson.Schema is JsonElement esquema
                    ? SanitizarSchema(esquema)
                    : null;

                generationConfig = new GeminiGenerationConfig("application/json", responseJsonSchema);
            }

            return new GeminiRequest(
                systemParts.Count > 0 ? new GeminiSystemInstruction(systemParts) : null,
                contents,
                generationConfig);
        }

        private static List<GeminiPart> ConstruirParts(ChatMessage message)
        {
            var parts = new List<GeminiPart>();

            foreach (var content in message.Contents)
            {
                switch (content)
                {
                    case TextContent texto:
                        parts.Add(new GeminiPart { Text = texto.Text });
                        break;
                    case DataContent imagen:
                        parts.Add(new GeminiPart
                        {
                            InlineData = new GeminiInlineData(
                                imagen.MediaType ?? "application/octet-stream",
                                Convert.ToBase64String(imagen.Data.Span))
                        });
                        break;
                }
            }

            return parts;
        }

        /// <summary>
        /// Keywords que Microsoft.Extensions.AI emite en el JSON Schema y que Gemini rechaza
        /// con 400 INVALID_ARGUMENT. Si aparece un 400 nuevo por este motivo, el keyword
        /// culpable se ve en el request guardado en LogServicioExterno y se agrega acá.
        /// </summary>
        private static readonly HashSet<string> KeywordsNoSoportados = new(StringComparer.Ordinal)
        {
            "additionalProperties", "$schema", "$id", "$comment", "default", "title", "examples", "const"
        };

        /// <summary>
        /// Adapta el JSON Schema generado a partir del tipo de respuesta al subconjunto que acepta
        /// Gemini: elimina los keywords no soportados y normaliza los tipos anulables, que Gemini
        /// expresa como "nullable": true y no como "type": ["string", "null"].
        /// </summary>
        private static JsonNode? SanitizarSchema(JsonElement schema)
        {
            var nodo = JsonNode.Parse(schema.GetRawText());

            if (nodo is not null)
                LimpiarNodo(nodo);

            return nodo;
        }

        private static void LimpiarNodo(JsonNode nodo)
        {
            switch (nodo)
            {
                case JsonObject objeto:
                    foreach (var clave in objeto.Select(propiedad => propiedad.Key).Where(KeywordsNoSoportados.Contains).ToList())
                        objeto.Remove(clave);

                    NormalizarTipoAnulable(objeto);

                    foreach (var propiedad in objeto.ToList())
                    {
                        if (propiedad.Value is not null)
                            LimpiarNodo(propiedad.Value);
                    }

                    break;

                case JsonArray arreglo:
                    foreach (var elemento in arreglo.ToList())
                    {
                        if (elemento is not null)
                            LimpiarNodo(elemento);
                    }

                    break;
            }
        }

        private static void NormalizarTipoAnulable(JsonObject objeto)
        {
            if (objeto["type"] is not JsonArray tipos)
                return;

            var valores = tipos.Select(tipo => tipo?.GetValue<string>()).ToList();
            var tipoBase = valores.FirstOrDefault(tipo => tipo is not null && tipo != "null");

            if (tipoBase is null)
                return;

            objeto["type"] = tipoBase;

            if (valores.Contains("null"))
                objeto["nullable"] = true;
        }

        private sealed record GeminiRequest(
            [property: JsonPropertyName("system_instruction")] GeminiSystemInstruction? SystemInstruction,
            [property: JsonPropertyName("contents")] List<GeminiContent> Contents,
            [property: JsonPropertyName("generationConfig")] GeminiGenerationConfig? GenerationConfig);

        private sealed record GeminiSystemInstruction(
            [property: JsonPropertyName("parts")] List<GeminiPart> Parts);

        private sealed record GeminiContent(
            [property: JsonPropertyName("role")] string Role,
            [property: JsonPropertyName("parts")] List<GeminiPart> Parts);

        private sealed class GeminiPart
        {
            [JsonPropertyName("text")]
            public string? Text { get; set; }

            [JsonPropertyName("inline_data")]
            public GeminiInlineData? InlineData { get; set; }
        }

        private sealed record GeminiInlineData(
            [property: JsonPropertyName("mime_type")] string MimeType,
            [property: JsonPropertyName("data")] string Data);

        private sealed record GeminiGenerationConfig(
            [property: JsonPropertyName("responseMimeType")] string? ResponseMimeType,
            [property: JsonPropertyName("responseJsonSchema")] JsonNode? ResponseJsonSchema);

        private sealed class GeminiResponse
        {
            [JsonPropertyName("candidates")]
            public List<GeminiCandidate>? Candidates { get; set; }
        }

        private sealed class GeminiCandidate
        {
            [JsonPropertyName("content")]
            public GeminiResponseContent? Content { get; set; }
        }

        private sealed class GeminiResponseContent
        {
            [JsonPropertyName("parts")]
            public List<GeminiPart>? Parts { get; set; }
        }
    }
}
