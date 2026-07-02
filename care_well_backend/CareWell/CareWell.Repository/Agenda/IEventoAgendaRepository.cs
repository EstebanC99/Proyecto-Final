using CareWell.Domain.Agenda;

namespace CareWell.Repository.Agenda
{
    public interface IEventoAgendaRepository : IRepository<EventoAgenda>
    {
        List<EventoAgenda> GetAllByPersonaEnRango(int personaID, DateTime fechaDesde, DateTime fechaHasta);
        List<EventoAgenda> GetAllWithGeneracionEventoSaludPendiente(int personaID, DateTime fechaHasta);
    }
}