using CareWell.Domain.General;

namespace CareWell.Repository.General
{
    public interface IResumenDiarioRepository : IRepository<ResumenDiario>
    {
        ResumenDiario GetByPersona(int personaID);
    }
}