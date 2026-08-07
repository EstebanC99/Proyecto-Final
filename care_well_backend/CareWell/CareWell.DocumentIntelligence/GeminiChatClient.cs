using Microsoft.Extensions.AI;
using System.Net.Http.Json;
using System.Runtime.CompilerServices;
using System.Text.Json.Serialization;

namespace CareWell.DocumentIntelligence
{
    /// <summary>
    /// Cliente mínimo de IChatClient para Gemini vía Vertex AI / Agent Platform (publisher models),
    /// sin pasar por ningún endpoint compatible con OpenAI ni por paquetes de terceros. Se usa este
    /// producto y no la API "AI Studio" (generativelanguage.googleapis.com) porque esta última aplica
    /// un bloqueo geográfico/antiabuso a IPs de datacenter que resultó intermitente incluso con
    /// billing habilitado; Vertex AI está pensado para uso servidor-a-servidor y no lo sufre.
    /// Habla directamente el formato REST de Gemini, incluyendo el forzado de salida JSON
    /// (responseMimeType) cuando el llamador pide un tipo estructurado vía GetResponseAsync&lt;T&gt;.
    /// </summary>
    internal sealed class GeminiChatClient : IChatClient
    {
        private const string BaseUrl = "https://aiplatform.googleapis.com/v1/publishers/google/models";

        private readonly HttpClient httpClient;
        private readonly string apiKey;
        private readonly string model;

        public GeminiChatClient(string apiKey, string model, TimeSpan timeout)
        {
            this.apiKey = apiKey;
            this.model = model;
            this.httpClient = new HttpClient { Timeout = timeout };
        }

        public async Task<ChatResponse> GetResponseAsync(
            IEnumerable<ChatMessage> messages,
            ChatOptions? options = null,
            CancellationToken cancellationToken = default)
        {
            var request = ConstruirRequest(messages, options);
            var url = $"{BaseUrl}/{model}:generateContent";

            using var httpRequest = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = JsonContent.Create(request)
            };
            httpRequest.Headers.Add("x-goog-api-key", this.apiKey);

            using var httpResponse = await this.httpClient.SendAsync(httpRequest, cancellationToken);

            if (!httpResponse.IsSuccessStatusCode)
            {
                var cuerpoError = await httpResponse.Content.ReadAsStringAsync(cancellationToken);
                throw new HttpRequestException(
                    $"Gemini respondió {(int)httpResponse.StatusCode} {httpResponse.StatusCode}: {cuerpoError}");
            }

            var geminiResponse = await httpResponse.Content.ReadFromJsonAsync<GeminiResponse>(cancellationToken);
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

        private static GeminiRequest ConstruirRequest(IEnumerable<ChatMessage> messages, ChatOptions? options)
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

            var generationConfig = options?.ResponseFormat is ChatResponseFormatJson
                ? new GeminiGenerationConfig("application/json")
                : null;

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
            [property: JsonPropertyName("responseMimeType")] string? ResponseMimeType);

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
