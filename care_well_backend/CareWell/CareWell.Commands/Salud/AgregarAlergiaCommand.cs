namespace CareWell.Commands.Salud
{
    public class AgregarAlergiaCommand
    {
        public int ID { get; set; }
        public string Nombre { get; set; }
        public string Reaccion { get; set; }
        public string? Medicamento { get; set; }
    }
}
