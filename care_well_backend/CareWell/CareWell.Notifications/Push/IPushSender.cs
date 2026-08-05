namespace CareWell.Notifications.Push
{
    public interface IPushSender
    {
        Task<ResultadoEnvioPush> Enviar(List<string> tokens, MensajePush mensaje, CancellationToken cancellationToken);
    }
}
