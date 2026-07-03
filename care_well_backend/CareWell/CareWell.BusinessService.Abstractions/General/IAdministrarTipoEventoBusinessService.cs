using CareWell.DataViews.General;

namespace CareWell.BusinessService.Abstractions.General
{
    public interface IAdministrarTipoEventoBusinessService
    {
        List<TipoEventoDataView> ObtenerTodos();
    }
}
