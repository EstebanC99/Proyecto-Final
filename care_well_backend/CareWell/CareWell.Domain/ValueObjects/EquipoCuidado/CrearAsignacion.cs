using CareWell.Domain.Auth;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.EquipoCuidado
{
    public record CrearAsignacion(
        Persona PersonaCuidada,
        Persona Colaborador,
        Persona Asignador,
        RolCuidado Rol,
        List<PermisoCuidado> Permisos
        );
}
