namespace CareWell.DataViews.Salud
{
    public class FichaSaludAlergiaDataView : BaseDataView
    {
        public string Nombre { get; set; }
        public string Reaccion { get; set; }
        public string? Medicamento { get; set; }
    }
}
