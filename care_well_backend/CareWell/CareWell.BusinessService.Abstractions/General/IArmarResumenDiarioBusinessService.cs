using CareWell.DataViews.General;

namespace CareWell.BusinessService.Abstractions.General
{
    public interface IArmarResumenDiarioBusinessService
    {
        Task<ResumenDiarioDataView> Armar(int personaCuidadaID, string personaCuidadaNombre, CancellationToken cancellationToken);
    }
}
