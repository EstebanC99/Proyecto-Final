using CareWell.Domain.Auth;
using CareWell.Global.Enumeraciones.Auth;

namespace CareWell.Repository.Auth
{
    public interface ICodigoVerificacionRepository : IRepository<CodigoVerificacion>
    {
        CodigoVerificacion? GetVigentePorUsuario(Usuario usuario, TipoCodigoVerificacionEnum tipo);
    }
}
