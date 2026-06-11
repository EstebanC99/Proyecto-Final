using CareWell.Domain.General;

namespace CareWell.Repository.General
{
    public class PersonaRepository : Repository<Persona>, IPersonaRepository
    {
        public PersonaRepository(CareWellDbContext dbContext) : base(dbContext)
        {
        }
    }
}
