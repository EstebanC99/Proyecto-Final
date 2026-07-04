namespace CareWell.DataViews.Salud
{
    public class HabitoVidaRealizacionDataView : BaseEntityDataView
    {
        public int HabitoVidaID { get; set; }

        public string? Comentarios{ get; set; }

        public DateTime FechaHoraRealizacion { get; set; }
    }
}
