using CareWell.DataViews.General;
using CareWell.Queries.General;

namespace CareWell.BusinessService.Abstractions.General
{
    public interface IResumenDiarioBusinessService
    {
        Task<ResumenDiarioDataView> Generar(GenerarResumenDiarioQuery query, CancellationToken cancellationToken);
    }
}
