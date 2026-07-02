using CareWell.Domain.Salud;

namespace CareWell.Repository.Salud
{
    public class EventoSaludRepository : Repository<EventoSalud>, IEventoSaludRepository
    {
        public EventoSaludRepository(CareWellDbContext dbContext) : base(dbContext)
        {

        }

        public bool ExistePorOrigen(int eventoAgendaID, DateTime fechaOcurrencia)
        {
            return this.DbSet
                .Any(e => e.EventoAgenda != null
                       && e.EventoAgenda.ID == eventoAgendaID
                       && e.FechaOcurrenciaEventoAgenda == fechaOcurrencia);
        }
    }
}
