namespace CareWell.Commands.Auth
{
    public class ConfirmarResetContrasenaCommand
    {
        public string Email { get; set; }
        public string Codigo { get; set; }
        public string ContrasenaNueva { get; set; }
    }
}
