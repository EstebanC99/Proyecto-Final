namespace CareWell.DataViews.Salud
{
    public class HabitoVidaDataView : BaseEntityDataView
    {
        public BaseEntityDataView Persona { get; set; }

        public BaseEntityDataView Tipo { get; set; }

        public bool Activo { get; set; }

        public HabitoVidaRealizacionDataView? Realizacion { get; set; }
    }
}
