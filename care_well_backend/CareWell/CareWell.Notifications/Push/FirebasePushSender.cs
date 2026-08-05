using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using FirebaseAdmin.Messaging;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace CareWell.Notifications.Push
{
    public class FirebasePushSender : IPushSender
    {
        /// <summary>Máximo de tokens por lote que admite la API de FCM.</summary>
        private const int TamanoLote = 500;

        private FirebaseMessaging Messaging { get; set; }
        private PushOptions PushOptions { get; set; }
        private ILogger<FirebasePushSender> Logger { get; set; }

        public FirebasePushSender(FirebaseMessaging messaging,
                                  IOptions<PushOptions> options,
                                  ILogger<FirebasePushSender> logger)
        {
            this.Messaging = messaging;
            this.PushOptions = options.Value;
            this.Logger = logger;
        }

        public async Task<ResultadoEnvioPush> Enviar(List<string> tokens, MensajePush mensaje, CancellationToken cancellationToken)
        {
            if (tokens is null || tokens.Count == default)
                return ResultadoEnvioPush.Vacio();

            var enviados = default(int);
            var fallidos = default(int);
            var tokensInvalidos = new List<string>();

            using var timeout = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
            timeout.CancelAfter(TimeSpan.FromSeconds(this.PushOptions.TimeoutSegundos));

            foreach (var lote in tokens.Distinct().Chunk(TamanoLote))
            {
                var mensajeMulticast = this.ConstruirMensaje(lote.ToList(), mensaje);

                try
                {
                    var respuesta = await this.Messaging.SendEachForMulticastAsync(mensajeMulticast, timeout.Token);

                    enviados += respuesta.SuccessCount;
                    fallidos += respuesta.FailureCount;

                    tokensInvalidos.AddRange(this.ObtenerTokensInvalidos(lote.ToList(), respuesta));
                }
                catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested) { throw; }
                catch (Exception ex)
                {
                    this.Logger.LogError(ex, "Falló el envío de notificaciones push a {Cantidad} dispositivos.", lote.Length);

                    throw new ServicioNoDisponibleException(Mensajes.ServicioDeNotificacionesPushNoDisponible);
                }
            }

            return new ResultadoEnvioPush(enviados, fallidos, tokensInvalidos);
        }

        #region Metodos Privados

        private MulticastMessage ConstruirMensaje(List<string> tokens, MensajePush mensaje)
        {
            return new MulticastMessage
            {
                Tokens = tokens,
                Notification = new Notification
                {
                    Title = mensaje.Titulo,
                    Body = mensaje.Cuerpo
                },
                Data = mensaje.Datos,
                Android = new AndroidConfig
                {
                    Priority = Priority.High,
                    Notification = new AndroidNotification
                    {
                        ChannelId = mensaje.CanalID,
                        Sound = "default"
                    }
                }
            };
        }

        /// <summary>
        /// Detecta los tokens rechazados de forma permanente. Los errores
        /// transitorios (indisponibilidad, cuota) NO se reportan como inválidos:
        /// esos dispositivos siguen siendo válidos y deben conservarse.
        /// </summary>
        private List<string> ObtenerTokensInvalidos(List<string> tokens, BatchResponse respuesta)
        {
            var invalidos = new List<string>();

            for (int i = default; i < respuesta.Responses.Count; i++)
            {
                var item = respuesta.Responses[i];

                if (item.IsSuccess)
                    continue;

                var codigo = item.Exception?.MessagingErrorCode;

                if (codigo == MessagingErrorCode.Unregistered || codigo == MessagingErrorCode.InvalidArgument)
                {
                    invalidos.Add(tokens[i]);
                    continue;
                }

                this.Logger.LogWarning("Error transitorio al enviar push: {Codigo}", codigo);
            }

            return invalidos;
        }

        #endregion
    }
}
