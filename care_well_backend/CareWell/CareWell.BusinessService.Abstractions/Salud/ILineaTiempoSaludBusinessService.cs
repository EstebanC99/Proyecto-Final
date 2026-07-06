using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;

namespace CareWell.BusinessService.Abstractions.Salud
{
    public interface ILineaTiempoSaludBusinessService
    {
        List<EventoBaseDataView> ObtenerPorFechas(LineaTiempoSaludQuery query);
    }
}
