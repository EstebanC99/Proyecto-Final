namespace CareWell.DataViews.Salud
{
    public class EventoBaseDataView : BaseDataView
    {
        public string Descripcion { get; set; }

        public string CategoriaEvento { get; set; }

        public DateTime FechaHora { get; set; }
    }
}
