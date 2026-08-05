using CareWell.DataViews.General;

namespace CareWell.DataViews.Emergencias
{
    public class EmergenciaDataView : BaseDataView
    {
        public PersonaDataView Persona { get; set; }
        public PersonaDataView Activador { get; set; }
        public DateTime FechaHora { get; set; }
        public string? Descripcion { get; set; }
    }
}
