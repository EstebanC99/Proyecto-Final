using CareWell.Commands.Auditoria;

namespace CareWell.BusinessService.Abstractions.Auditoria
{
    public interface IRegistrarLogExcepcionBusinessService
    {
        void Registrar(RegistrarLogExcepcionCommand command);
    }
}
