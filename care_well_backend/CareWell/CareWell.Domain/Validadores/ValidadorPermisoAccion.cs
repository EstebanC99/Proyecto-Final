using CareWell.Domain.Auth;
using CareWell.Domain.EquipoCuidado;
using CareWell.Global.Constantes.EquipoCuidado;

namespace CareWell.Domain.Validadores
{
    public class ValidadorPermisoAccion : IValidadorPermisoAccion
    {
        public bool PermiteModificarDatosPersonaCargo(AsignacionCuidado asignacionCuidado, Usuario usuarioModificador)
        {
            if (asignacionCuidado.Colaborador.ID != usuarioModificador.Persona.ID)
                return false;

            if (asignacionCuidado.Rol.ID != RolesCuidado.Responsable)
                return false;

            return true;
        }
    }
}
