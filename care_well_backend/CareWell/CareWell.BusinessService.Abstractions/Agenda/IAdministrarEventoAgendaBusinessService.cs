using CareWell.Commands.Agenda;
using CareWell.DataViews.Agenda;
using CareWell.Queries.Agenda;

namespace CareWell.BusinessService.Abstractions.Agenda
{
    public interface IAdministrarEventoAgendaBusinessService
    {
        List<OcurrenciaEventoAgendaDataView> ObtenerOcurrencias(ObtenerEventosAgendaQuery query);

        void Crear(CrearEventoAgendaCommand command);
        void Modificar(ModificarEventoAgendaCommand command);
        void Eliminar(int eventoAgendaID);
        void CancelarOcurrencia(CancelarOcurrenciaEventoAgendaCommand command);
    }
}
