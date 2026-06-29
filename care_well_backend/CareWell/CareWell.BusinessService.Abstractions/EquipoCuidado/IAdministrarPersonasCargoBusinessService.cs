using CareWell.Commands.EquipoCuidado;
using CareWell.DataViews.EquipoCuidado;

namespace CareWell.BusinessService.Abstractions.EquipoCuidado
{
    public interface IAdministrarPersonasCargoBusinessService
    {
        List<AsignacionCuidadoDataView> ObtenerAsignacionesUsuarioLogueado();

        void CrearPersonaCargo(CrearPersonaCargoCommand command);
        void ModificarPersonaCargo(ModificarPersonaCargoCommand command);
    }
}
