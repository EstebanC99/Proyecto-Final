using CareWell.Commands.Auth;

namespace CareWell.BusinessService.Abstractions.Auth
{
    public interface IAdministrarDispositivoBusinessService
    {
        void Registrar(RegistrarDispositivoCommand command);
        void Eliminar(EliminarDispositivoCommand command);
    }
}
