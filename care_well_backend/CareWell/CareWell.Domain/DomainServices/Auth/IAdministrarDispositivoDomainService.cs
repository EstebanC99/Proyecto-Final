using CareWell.Domain.Auth;

namespace CareWell.Domain.DomainServices.Auth
{
    public interface IAdministrarDispositivoDomainService
    {
        void DesactivarTodosDelUsuario(Usuario usuario);
    }
}
