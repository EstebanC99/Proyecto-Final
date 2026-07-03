namespace CareWell.DataViews.Salud
{
    public class NotaEventoSaludDataView
    {
        public int ID { get; set; }

        public BaseEntityDataView Autor { get; set; }

        public DateTime FechaHora { get; set; }

        public string Contenido { get; set; }
    }
}
