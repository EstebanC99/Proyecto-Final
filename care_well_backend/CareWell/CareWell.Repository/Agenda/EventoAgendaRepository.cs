using CareWell.Domain.Agenda;

namespace CareWell.Repository.Agenda
{
    public class EventoAgendaRepository : Repository<EventoAgenda>, IEventoAgendaRepository
    {
        public EventoAgendaRepository(CareWellDbContext dbContext) : base(dbContext)
        {

        }

        public List<EventoAgenda> GetAllByPersonaEnRango(int personaID, DateTime fechaDesde, DateTime fechaHasta)
        {
            return this.DbSet
                .Where(e => e.Persona.ID == personaID
                         && e.FechaHoraInicio <= fechaHasta
                         && (e.ReglaRecurrencia != null || e.FechaHoraInicio >= fechaDesde))
                .ToList();
        }

        public List<EventoAgenda> GetAllWithGeneracionEventoSaludPendiente(int personaID, DateTime fechaHasta)
        {
            return this.DbSet
                .Where(e => e.Persona.ID == personaID
                         && e.GenerarEventoSalud
                         && e.FechaHoraInicio <= fechaHasta
                         && (e.FechaUltimaGeneracionEventoSalud == null || e.FechaUltimaGeneracionEventoSalud < fechaHasta))
                .ToList();
        }
    }
}
