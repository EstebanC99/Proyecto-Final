namespace CareWell.Notifications.Push
{
    public record ResultadoEnvioPush(
        int Enviados,
        int Fallidos,
        List<string> TokensInvalidos
    )
    {
        public static ResultadoEnvioPush Vacio() => new(0, 0, new List<string>());
    }
}
