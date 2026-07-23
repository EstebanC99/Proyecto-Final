using CareWell.Domain.Auth;
using CareWell.Global.Enumeraciones.Auth;

namespace CareWell.Domain.ValueObjects.Auth
{
    public record CrearCodigoVerificacion(
        Usuario Usuario,
        TipoCodigoVerificacionEnum Tipo,
        string CodigoHash,
        DateTime Expiracion
    );
}
