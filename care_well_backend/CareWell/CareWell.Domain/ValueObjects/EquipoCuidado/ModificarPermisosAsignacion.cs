using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.EquipoCuidado
{
    public record ModificarPermisosAsignacion(
        Persona Asignador,
        List<PermisoCuidado> NuevosPermisos
        );
}
