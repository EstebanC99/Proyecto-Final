using CareWell.DataViews;

namespace CareWell.BusinessService.Abstractions.Salud
{
    public interface IAdministrarTipoHabitoVidaBusinessService
    {
        List<BaseEntityDataView> ObtenerTodos();
    }
}
