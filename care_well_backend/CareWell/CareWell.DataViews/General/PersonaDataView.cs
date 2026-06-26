namespace CareWell.DataViews.General
{
    public class PersonaDataView : BaseDataView
    {
        public string Nombre { get; set; }

        public string Apellido { get; set; }

        public string Documento { get; set; }

        public DateTime FechaNacimiento { get; set; }

        public string? Email { get; set; }

        public string? Telefono { get; set; }

        public string? ImagenPath { get; set; }
    }
}
