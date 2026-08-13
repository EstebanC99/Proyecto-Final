using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;

namespace CareWell.BusinessService.Abstractions.Salud
{
    public interface IResumenSaludBusinessService
    {
        ResumenSaludDataView Obtener(ResumenSaludQuery query);
    }
}
