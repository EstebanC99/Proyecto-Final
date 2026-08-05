namespace CareWell.Notifications.Push
{
    public class PushOptions
    {
        public string RutaCredenciales { get; set; } = string.Empty;
        public string CredencialesJson { get; set; } = string.Empty;
        public int TimeoutSegundos { get; set; } = 30;
        public bool EstaConfigurado =>
            !string.IsNullOrWhiteSpace(this.CredencialesJson) ||
            !string.IsNullOrWhiteSpace(this.RutaCredenciales);
    }
}
