namespace CareWell.DataViews.Salud
{
    public class FichaSaludEnfermedadDataView : BaseDataView
    {
        public string Nombre { get; set; }
        public bool Vigente { get; set; }
        public string? Observacion { get; set; }
    }
}
