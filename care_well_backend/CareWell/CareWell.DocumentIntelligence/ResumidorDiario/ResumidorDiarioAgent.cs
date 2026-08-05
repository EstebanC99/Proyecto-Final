using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Microsoft.Extensions.AI;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace CareWell.DocumentIntelligence.ResumidorDiario
{
    public class ResumidorDiarioAgent : IResumidorDiarioAgent
    {
        private const string SystemPrompt = """
        Sos un asistente que redacta resúmenes claros y empáticos para el CUIDADOR de una persona.
        A partir de datos estructurados de Agenda, Eventos de Salud, Estados de Ánimo y Hábitos de Vida,
        generás un resumen del día de hoy y una previsión con los compromisos de mañana.

        Significado de los datos que recibís:
        - "Agenda": compromisos AGENDADOS que todavía NO ocurrieron. Van desde el momento actual
          hasta el final del día de mañana. "FechaHoraOcurrencia" es el inicio y "FechaHoraFin" el fin.
          Nunca los describas como algo ya hecho.
        - "Eventos de Salud", "Estados de Ánimo" y "Hábitos de Vida": registros del día de HOY.
          En Hábitos, "Finalizado" indica si la persona ya lo cumplió hoy.

        Reglas:
        - Escribí en español, en tono cálido, claro y directo. Dirigite al cuidador.
        - NO diagnostiques ni des indicaciones médicas. Si detectás algo que requiere atención
          (ej. valores fuera de rango, síntomas repetidos, medicación no tomada), señalálo como
          un punto a tener en cuenta y sugerí consultar a un profesional, sin alarmar.
        - Basate ÚNICAMENTE en los datos provistos. No invelores.
          En particular, NO inventes compromisos de agenda: si no están en "Agenda", no existen.
        - Mencioná los horarios de los compromisos de agendos.
        - Si una sección no tiene datos, indicá "Sin registros" en lugar de omitirla.
        - Priorizá lo accionable: qué pasó, qué está pendiee vigilar.
        - Devolvé SOLO el texto del resumen, sin encabezados de código ni explicaciones extra.

        Estructura de salida:
        RESUMEN DE HOY
        (estado general en 1-2 oraciones)
        - Salud: (solo los eventos de salud que pasaron)
        - Ánimo: (resumen de como estuvo sintiendose en el dia)
        - Hábitos: (completados y sin completar)
        - Pendiente hoy: (compromisos de Agenda que todavía faltan hoy; si no hay, "Sin compromisos de agenda pendientes para hoy")

        MAÑANA
        - Compromisos agendados: (los de Agenda que caen mañana, con horario; si no hay, "Sin compromisos agendados")
        - Habitos: (todos los hábitos que debe cumplir diariamente)

        A TENER EN CUENTA (opcional)
        - (recordatorios derivados de lo de hoy, sin inventar compromisos)
        """;

        private IChatClient ChatClient { get; set; }

        public ResumidorDiarioAgent(IChatClient chatClient)
        {
            this.ChatClient = chatClient;
        }

        public async Task<string?> ArmarResumen(ResumidorTextoAgentRequest request, CancellationToken cancellationToken)
        {
            var messages = new List<ChatMessage>
            {
                new ChatMessage(ChatRole.System, SystemPrompt),
                new ChatMessage(ChatRole.User, ConstruirPromptUsuario(request)),
            };

            try
            {
                var response = await this.ChatClient.GetResponseAsync(messages, cancellationToken: cancellationToken);

                return response.Text;
            }
            catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested) { throw; }
            catch { throw new ServicioNoDisponibleException(Mensajes.ServicioDeResumenDiarioNoDisponible); }
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
                Fecha de hoy: {request.FechaHoy:dd-MM-yyyy}
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
