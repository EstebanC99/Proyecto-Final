using CareWell.Domain.Auditoria;

namespace CareWell.Repository.Auditoria
{
    public interface ILogServicioExternoRepository
    {
        void Add(LogServicioExterno logServicioExterno);
    }
}
