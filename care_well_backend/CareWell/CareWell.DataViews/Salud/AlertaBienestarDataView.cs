namespace CareWell.DataViews.Salud
{
    public class AlertaBienestarDataView
    {
        public string Tipo { get; set; }
        public string Severidad { get; set; }
        public string Categoria { get; set; }
        public string Mensaje { get; set; }
        public DateTime FechaDeteccion { get; set; }
        public int? HabitoVidaID { get; set; }
    }
}