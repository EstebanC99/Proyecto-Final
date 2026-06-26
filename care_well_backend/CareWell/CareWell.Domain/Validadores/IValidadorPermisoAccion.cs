using CareWell.Domain.Auth;
using CareWell.Domain.EquipoCuidado;

namespace CareWell.Domain.Validadores
{
    public interface IValidadorPermisoAccion
    {
        bool PermiteModificarDatosPersonaCargo(AsignacionCuidado asignacionCuidado, Usuario usuarioModificador);
    }
}