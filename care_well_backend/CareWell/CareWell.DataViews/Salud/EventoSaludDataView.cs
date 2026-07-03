using CareWell.DataViews.General;

namespace CareWell.DataViews.Salud
{
    public class EventoSaludDataView : BaseEntityDataView
    {
        public BaseEntityDataView Persona { get; set; }

        public TipoEventoDataView Tipo { get; set; }

        public DateTime FechaHora { get; set; }

        public List<NotaEventoSaludDataView> Notas { get; set; }

        public DateTime? FechaOcurrenciaEventoAgenda { get; set; }
    }
}
