using CareWell.Domain.Salud;

namespace CareWell.Repository.Salud
{
    public class AlertaBienestarRepository : Repository, IAlertaBienestarRepository
    {
        public AlertaBienestarRepository(CareWellDbContext dbContext) : base(dbContext)
        {

        }

        public List<PersonaEstadoAnimo> GetEstadosAnimo(int personaID, DateTime fechaDesde)
        {
            return this.DbContext.Set<PersonaEstadoAnimo>()
                .Where(e => e.Persona.ID == personaID
                         && e.FechaHora > fechaDesde)
                .ToList();
        }

        public List<HabitoVida> GetHabitosActivos(int personaID)
        {
            return this.DbContext.Set<HabitoVida>()
                .Where(h => h.Persona.ID == personaID
                         && h.Activo)
                .ToList();
        }
    }
}
