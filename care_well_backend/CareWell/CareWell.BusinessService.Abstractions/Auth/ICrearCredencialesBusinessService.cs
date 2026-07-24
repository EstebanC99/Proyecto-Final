using CareWell.Commands.Auth;

namespace CareWell.BusinessService.Abstractions.Auth
{
    public interface ICrearCredencialesBusinessService
    {
        void Crear(CrearCredencialesCommand command);
    }
}
