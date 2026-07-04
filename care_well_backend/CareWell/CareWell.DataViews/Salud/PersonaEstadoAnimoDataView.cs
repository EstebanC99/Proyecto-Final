namespace CareWell.DataViews.Salud
{
    public class PersonaEstadoAnimoDataView
    {
        public int ID { get; set; }

        public BaseEntityDataView EstadoAnimo { get; set; }

        public DateTime FechaHora { get; set; }

        public string? Observaciones { get; set; }
    }
}
