namespace CareWell.Commands.Salud
{
    public class RegistrarEstadoAnimoCommand
    {
        public int PersonaID { get; set; }

        public int EstadoAnimoID { get; set; }

        public string? Observaciones { get; set; }
    }
}
