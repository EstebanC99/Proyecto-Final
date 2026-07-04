namespace CareWell.Queries.Salud
{
    public class PersonaEstadoAnimoPorFechaQuery : PersonaEstadoAnimoHoyQuery
    {
        public DateTime FechaDesde { get; set; }

        public DateTime FechaHasta { get; set; }
    }
}
