using CareWell.Domain.General;

namespace CareWell.Repository.General
{
    public class ResumenDiarioRepository : Repository<ResumenDiario>, IResumenDiarioRepository
    {
        public ResumenDiarioRepository(CareWellDbContext dbContext) : base(dbContext) { }

        public ResumenDiario GetByPersona(int personaID)
        {
            return this.DbSet.FirstOrDefault(r => r.Persona.ID == personaID);
        }
    }
}
