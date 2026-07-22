using CareWell.Domain.Auth;

namespace CareWell.Repository.Auth
{
    public interface ICodigoVerificacionEmailRepository : IRepository<CodigoVerificacionEmail>
    {
        CodigoVerificacionEmail? GetVigentePorUsuario(int usuarioID);
    }
}
