using CareWell.Commands.Auth;

namespace CareWell.BusinessService.Abstractions.Auth
{
    public interface ICrearCuentaBusinessService
    {
        void Crear(CrearCuentaCommand command);
    }
}
