namespace CareWell.Notifications.Push
{
    public record MensajePush
    (
        string Titulo,
        string Cuerpo,
        string CanalID,
        Dictionary<string, string> Datos
    );
}
