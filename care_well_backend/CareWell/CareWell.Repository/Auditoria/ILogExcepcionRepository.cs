using CareWell.Domain.Auditoria;

namespace CareWell.Repository.Auditoria
{
    public interface ILogExcepcionRepository
    {
        void Add(LogExcepcion logExcepcion);
    }
}
