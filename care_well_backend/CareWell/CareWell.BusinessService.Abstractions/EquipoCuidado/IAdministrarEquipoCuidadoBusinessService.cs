using CareWell.Commands.EquipoCuidado;
using CareWell.DataViews.EquipoCuidado;

namespace CareWell.BusinessService.Abstractions.EquipoCuidado
{
    public interface IAdministrarEquipoCuidadoBusinessService
    {
        List<AsignacionCuidadoDataView> ObtenerAsignacionesUsuarioLogueado();

        void CrearPersonaCargo(CrearPersonaCargoCommand command);
    }
}
