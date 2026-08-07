namespace CareWell.DocumentIntelligence
{
    public class IAOptions
    {
        public string ApiKey { get; set; } = string.Empty;
        public string ModeloVision { get; set; } = "gemini-2.5-flash-lite";
        public string ModeloTexto { get; set; } = "gemini-2.5-flash-lite";
        public int TimeoutSegundos { get; set; } = 100;
    }
}
