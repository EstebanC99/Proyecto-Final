using CareWell.Domain.Auth;

namespace CareWell.Domain.ValueObjects.Auth
{
    public record CrearCodigoVerificacionEmail(
        Usuario Usuario,
        string CodigoHash,
        DateTime Expiracion
    );
}
