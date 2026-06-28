using CareWell.Commands.EquipoCuidado;
using CareWell.DataViews.EquipoCuidado;

namespace CareWell.BusinessService.Abstractions.EquipoCuidado
{
    public interface IAdministrarPersonasCargoBusinessService
    {
        List<AsignacionCuidadoDataView> ObtenerAsignacionesUsuarioLogueado();

        void CrearPersonaCargo(CrearPersonaCargoCommand command);
        void ModificarPersonaCargo(ModificarPersonaCargoCommand command);
        void EliminarAsignacion(int asignacionCuidadoID);
        void ActivarAsignacion(int asignacionCuidadoID);
        void ReactivarAsignacion(int asignacionCuidadoID);
    }
}
