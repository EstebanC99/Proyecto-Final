using CareWell.Domain.Auth;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;

namespace CareWell.Domain.Validadores
{
    public interface IValidadorPermisoAccion
    {
        void ValidarPuedeModificarDatosPersonaCargo(AsignacionCuidado asignacionCuidado, Usuario usuarioModificador);
        void ValidarPuedeAdministrarEquipoCuidado(Persona personaCuidada, Persona asignador);
        void ValidarPuedeAdministrarAgenda(Persona personaCuidada, Persona solicitante);
        void ValidarVisualizacion(Persona personaCuidada, Persona solicitante);
    }
}