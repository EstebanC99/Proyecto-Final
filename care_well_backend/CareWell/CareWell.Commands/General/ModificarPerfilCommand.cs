namespace CareWell.Commands.General
{
    public class ModificarPerfilCommand
    {
        public int ID { get; set; }
        public string Nombre { get; set; }
        public string Apellido { get; set; }
        public string Documento { get; set; }
        public DateTime FechaNacimiento { get; set; }
        public string? Telefono { get; set; }
        public string? Imagen { get; set; }
    }
}
