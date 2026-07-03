using CareWell.DataViews.Salud;
using CareWell.Domain.Salud;
using CareWell.Queries.Salud;

namespace CareWell.Repository.Salud
{
    public interface IEventoSaludRepository : IRepository<EventoSalud>
    {
        List<EventoSaludDataView> ObtenerTodos(EventoSaludQuery query);
        bool ExistePorOrigen(int eventoAgendaID, DateTime fechaOcurrencia);
    }
}