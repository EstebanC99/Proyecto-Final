namespace CareWell.Commands.Salud
{
    public class AgregarEnfermedadCommand
    {
        public int ID { get; set; }
        public string Nombre { get; set; }
        public bool Vigente { get; set; }
        public string? Observacion { get; set; }
    }
}
