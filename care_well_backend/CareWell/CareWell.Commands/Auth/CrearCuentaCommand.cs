namespace CareWell.Commands.Auth
{
    public class CrearCuentaCommand
    {
        public string Nombre { get; set; }

        public string Apellido { get; set; }

        public string Documento { get; set; }

        public DateTime FechaNacimiento { get; set; }

        public string Email { get; set; }

        public string Telefono { get; set; }

        public string Contrasena { get; set; }

        public string? Imagen { get; set; }

        public string? ImagenDocumento { get; set; }
    }
}
