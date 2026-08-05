using CareWell.Domain.Auth;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;

namespace CareWell.Domain.Validadores
{
    public interface IValidadorPermisoAccion
    {
        void ValidarPuedeModificarDatosPersonaCargo(AsignacionCuidado asignacionCuidado, Usuario usuarioModificador);
        void ValidarPuedeAdministrarEquipoCuidado(Persona personaCuidada, Persona colaborador);
        void ValidarPuedeAdministrarAgenda(Persona personaCuidada, Persona colaborador);
        void ValidarPuedeAdministrarEventosSalud(Persona personaCuidada, Persona colaborador);
        void ValidarPuedeRegistrarHabitos(Persona personaCuidada, Persona colaborador);
        void ValidarPuedeAdministrarFichaSalud(Persona personaCuidada, Persona colaborador);
        void ValidarPuedeVerFichaSalud(Persona personaCuidada, Persona colaborador);
        void ValidarPuedeActivarEmergencia(Persona personaCuidada, Persona colaborador);
        void ValidarVisualizacion(Persona personaCuidada, Persona colaborador);
        void ValidarPuedeModificarPerfil(Persona personaCuidada, Persona colaborador);
    }
}