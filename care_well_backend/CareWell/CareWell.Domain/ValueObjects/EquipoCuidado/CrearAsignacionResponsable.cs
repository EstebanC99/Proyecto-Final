using CareWell.Domain.Auth;
using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.EquipoCuidado
{
    public record CrearAsignacionResponsable(
        Persona PersonaCuidada,
        Usuario UsuarioCreador
    );
}
