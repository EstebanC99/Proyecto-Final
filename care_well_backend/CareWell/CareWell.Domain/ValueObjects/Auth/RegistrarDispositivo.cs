using CareWell.Domain.Auth;
using CareWell.Global.Enumeraciones.Auth;

namespace CareWell.Domain.ValueObjects.Auth
{
    public record RegistrarDispositivo(
        Usuario Usuario,
        string Token,
        DispositivoPlataformasEnum Plataforma
    );
}
