using CareWell.Global.Enumeraciones.IA;

namespace CareWell.DocumentIntelligence
{
    public class IAOptions
    {
        public ProveedoresIAEnum Proveedor { get; set; } = ProveedoresIAEnum.VertexAI;
        public string? BaseUrlPersonalizada { get; set; }
        public string ApiKey { get; set; } = string.Empty;
        public string ModeloVision { get; set; }
        public string ModeloTexto { get; set; }
        public int TimeoutSegundos { get; set; } = 100;
        public bool EnviarResponseSchema { get; set; } = true;
    }
}
