using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Microsoft.Extensions.AI;
using Microsoft.Extensions.DependencyInjection;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace CareWell.DocumentIntelligence.ResumidorDiario
{
    public class ResumidorDiarioAgent : IResumidorDiarioAgent
    {
        private IChatClient ChatClient { get; set; }

        public ResumidorDiarioAgent(
            [FromKeyedServices(DocumentIntelligenceExtensions.ClienteTexto)] IChatClient chatClient)
        {
            this.ChatClient = chatClient;
        }

        public async Task<ResumidorDiarioAgentResponse> ArmarResumen(ResumidorTextoAgentRequest request, CancellationToken cancellationToken)
        {
            var systemPrompt = RecursosEmbebidos.Leer("resumidor-diario-system.md");

            var messages = new List<ChatMessage>
            {
                new ChatMessage(ChatRole.System, systemPrompt),
                new ChatMessage(ChatRole.User, ConstruirPromptUsuario(request)),
            };

            try
            {
                var response = await this.ChatClient.GetResponseAsync<ResumidorDiarioAgentResponse>(messages, cancellationToken: cancellationToken);

                return response.Result;
            }
            catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested) { throw; }
            catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or JsonException)
            {
                throw new ServicioNoDisponibleException(Mensajes.ServicioDeResumenDiarioNoDisponible);
            }
        }

        private static readonly JsonSerializerOptions OpcionesSerializacion = new()
        {
            DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
            Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
        };

        private static string ConstruirPromptUsuario(ResumidorTextoAgentRequest request)
        {
            string agenda = JsonSerializer.Serialize(request.EventosAgenda, OpcionesSerializacion);
            string salud = JsonSerializer.Serialize(request.EventosSalud, OpcionesSerializacion);
            string animo = JsonSerializer.Serialize(request.EstadosAnimo, OpcionesSerializacion);
            string habitos = JsonSerializer.Serialize(request.HabitosVida, OpcionesSerializacion);

            return $"""
                Nombre de la persona: {request.NombrePersona}
                Fecha y hora actual: {request.FechaHoy:dd-MM-yyyy HH:mm:ss}
                Fecha de mañana: {request.FechaManana:dd-MM-yyyy}

                Eventos de Agenda:
                {agenda}

                Eventos de Salud:
                {salud}

                Estados de Ánimo:
                {animo}

                Hábitos de Vida:
                {habitos}

                Generá el resumen siguiendo la estructura indicada.
                """;
        }
    }
}
