namespace CareWell.Queries.Salud
{
    public class LineaTiempoSaludQuery
    {
        public int PersonaID { get; set; }

        public DateTime FechaDesde { get; set; }

        public DateTime FechaHasta { get; set; }
    }
}
