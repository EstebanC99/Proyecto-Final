using CareWell.Domain.Auth;
using CareWell.Global.Enumeraciones.Auth;

namespace CareWell.Domain.DomainServices.Auth
{
    public interface IGestorCodigoVerificacionDomainService
    {
        string EmitirCodigo(Usuario usuario, TipoCodigoVerificacionEnum tipo);
        void ValidarYConsumir(Usuario usuario, TipoCodigoVerificacionEnum tipo, string codigoIngresado);
    }
}
