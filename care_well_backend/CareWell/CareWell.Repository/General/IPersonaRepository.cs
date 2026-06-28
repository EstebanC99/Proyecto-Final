using CareWell.Domain.General;

namespace CareWell.Repository.General
{
    public interface IPersonaRepository : IRepository<Persona>
    {
        Persona GetByEmail(string email);
    }
}