using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Microsoft.Extensions.AI;

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

            Devolvé el resultado únicamente como un objeto JSON con esta forma exacta:
            {
              "DNI": número entero sin puntos,
              "Nombre": "nombre o nombres",
              "Apellido": "apellido o apellidos"
            }

            Si algún dato no es legible en la imagen, devolvé 0 para DNI y una cadena vacía para Nombre o Apellido. No incluyas texto adicional, explicaciones ni marcas de formato como ```json.
            """;

        private IChatClient ChatClient { get; set; }

        public ReconocedorTextoDocumentoAgent(IChatClient chatClient)
        {
            this.ChatClient = chatClient;
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
                throw new ServicioNoDisponibleException(Mensajes.ServicioReconocimientoNoDisponible);
            }
            catch
            {
                return null;
            }
        }
    }
}
