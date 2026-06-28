using CareWell.Domain.General;

namespace CareWell.Repository.General
{
    public class PersonaRepository : Repository<Persona>, IPersonaRepository
    {
        public PersonaRepository(CareWellDbContext dbContext) : base(dbContext)
        {
        }

        public Persona GetByEmail(string email)
        {
            return this.DbSet.FirstOrDefault(p => p.Email == email);
        }
    }
}
