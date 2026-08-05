using Microsoft.Extensions.Logging;

namespace CareWell.Notifications.Push
{
    /// <summary>
    /// Implementación Null Object que se registra cuando no hay credenciales de
    /// Firebase configuradas. Permite levantar la API sin el proveedor de push
    /// (entornos de otros desarrolladores, CI) sin romper el arranque.
    /// </summary>
    public class PushSenderNulo : IPushSender
    {
        private ILogger<PushSenderNulo> Logger { get; set; }

        public PushSenderNulo(ILogger<PushSenderNulo> logger)
        {
            this.Logger = logger;
        }

        public Task<ResultadoEnvioPush> Enviar(List<string> tokens,
                                               MensajePush mensaje,
                                               CancellationToken cancellationToken)
        {
            this.Logger.LogWarning("Notificaciones push deshabilitadas (sin credenciales). Se omitió el envío a {Cantidad} dispositivos.",
                                   tokens?.Count ?? default);

            return Task.FromResult(ResultadoEnvioPush.Vacio());
        }
    }
}
