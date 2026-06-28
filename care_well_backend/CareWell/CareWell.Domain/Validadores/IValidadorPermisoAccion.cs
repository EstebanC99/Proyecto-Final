using CareWell.Domain.Auth;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;

namespace CareWell.Domain.Validadores
{
    public interface IValidadorPermisoAccion
    {
        bool PermiteModificarDatosPersonaCargo(AsignacionCuidado asignacionCuidado, Usuario usuarioModificador);
        bool PermiteAdministrarEquipoCuidado(Persona personaCuidada, Persona asignador);
    }
}