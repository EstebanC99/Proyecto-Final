namespace CareWell.DataViews.General
{
    public class PersonaImagenDataView
    {
        public byte[]? Contenido { get; set; }
        public string TipoContenido => "image/jpeg";
    }
}
