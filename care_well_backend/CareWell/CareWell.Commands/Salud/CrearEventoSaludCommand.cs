namespace CareWell.Commands.Salud
{
    public class CrearEventoSaludCommand
    {
        public int PersonaID { get; set; }

        public int TipoID { get; set; }

        public DateTime FechaHora { get; set; }

        public string Descripcion { get; set; }
    }
}
