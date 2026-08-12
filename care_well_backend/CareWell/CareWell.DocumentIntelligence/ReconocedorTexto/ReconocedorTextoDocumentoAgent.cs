using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Microsoft.Extensions.AI;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace CareWell.DocumentIntelligence.ReconocedorTexto
{
    public class ReconocedorTextoDocumentoAgent : IReconocedorTextoDocumentoAgent
    {
        private const string SystemPrompt = """
            Sos un experto en la lectura de documentos nacionales de identidad (DNI) argentinos, tanto del modelo nuevo (tarjeta) como del modelo antiguo.

            Tu única tarea es EXTRAER, tal como figuran en la imagen del documento provista, estos datos:
            - El número de documento (DNI).
            - El nombre o nombres de la persona.
            - El apellido o apellidos de la persona.

            Extraé únicamente lo que ves en la imagen. No valides, no compares con ningún dato externo ni asumas valores: transcribí exactamente lo que aparece impreso en el documento.

            Guías para ubicar cada campo:
            - El número de documento suele estar en negrita y con puntos separadores de miles; transcribilo sin los puntos.
            - El apellido y el nombre están a la derecha de la foto, bajo títulos separados; no los confundas entre sí.
            - El apellido está bajo el título "Apellido / Surname".
            - El nombre está bajo el título "Nombre / Name".

            La estructura de la respuesta está definida por el esquema; no la repitas.
            Si algún dato no es legible, devolvé 0 en DNI y una cadena vacía en Nombre o Apellido.
            """;

        private IChatClient ChatClient { get; set; }
        private ILogger<ReconocedorTextoDocumentoAgent> Logger { get; set; }

        public ReconocedorTextoDocumentoAgent(
            [FromKeyedServices(DocumentIntelligenceExtensions.ClienteVision)] IChatClient chatClient,
            ILogger<ReconocedorTextoDocumentoAgent> logger)
        {
            this.ChatClient = chatClient;
            this.Logger = logger;
        }

        public ReconocedorTextoDocumentoAgentResponse? ExtraerTexto(byte[] imagenDocumento)
        {
            var messages = new List<ChatMessage>
            {
                new ChatMessage(ChatRole.System, SystemPrompt),

                new ChatMessage(ChatRole.User, [new DataContent(imagenDocumento, "image/jpeg")])
            };

            try
            {
                var response = this.ChatClient
                    .GetResponseAsync<ReconocedorTextoDocumentoAgentResponse>(messages)
                    .GetAwaiter()
                    .GetResult();

                return response.Result;
            }
            catch (Exception ex) when (ex is HttpRequestException
                                          or TaskCanceledException
                                          or OperationCanceledException)
            {
                this.Logger.LogWarning(ex, "Servicio de reconocimiento de texto no disponible.");
                throw new ServicioNoDisponibleException(Mensajes.ServicioReconocimientoNoDisponible);
            }
            catch (Exception ex)
            {
                this.Logger.LogWarning(ex, "No se pudo extraer el texto del documento.");
                return null;
            }
        }
    }
}
