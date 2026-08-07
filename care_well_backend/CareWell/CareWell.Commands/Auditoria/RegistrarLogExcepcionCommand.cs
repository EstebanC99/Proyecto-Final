namespace CareWell.Commands.Auditoria
{
    public class RegistrarLogExcepcionCommand
    {
        public string Tipo { get; set; }
        public bool Controlada { get; set; }
        public string Mensaje { get; set; }
        public string StackTrace { get; set; }
        public string Ruta { get; set; }
        public string Verbo { get; set; }
        public string TraceIdentifier { get; set; }
        public int? UsuarioID { get; set; }
    }
}
