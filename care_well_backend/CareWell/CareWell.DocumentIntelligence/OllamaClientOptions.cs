namespace CareWell.DocumentIntelligence
{
    public class OllamaClientOptions
    {
        public string OllamaUrl { get; set; } = "http://localhost:11434";
        public string Modelo { get; set; } = "qwen2.5vl";
        public int TimeoutSegundos { get; set; } = 100;
    }
}
