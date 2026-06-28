using CareWell.Commands.EquipoCuidado;
using CareWell.DataViews.EquipoCuidado;
using CareWell.Queries.EquipoCuidado;

namespace CareWell.BusinessService.Abstractions.EquipoCuidado
{
    public interface IAdministrarEquipoCuidadoBusinessService
    {
        List<AsignacionCuidadoDataView> ObtenerAsignacionesPorPersonaCuidada(AsignacionCuidadoQuery query);

        void Asignar(CrearAsignacionCuidadoCommand command);
        void ModificarPermisos(ModificarPermisosAsignacionCommand command);
    }
}
