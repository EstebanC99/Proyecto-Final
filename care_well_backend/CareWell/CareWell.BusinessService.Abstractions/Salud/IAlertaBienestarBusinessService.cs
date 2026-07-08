using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;

namespace CareWell.BusinessService.Abstractions.Salud
{
    public interface IAlertaBienestarBusinessService
    {
        List<AlertaBienestarDataView> Obtener(AlertaBienestarQuery query);
    }
}
