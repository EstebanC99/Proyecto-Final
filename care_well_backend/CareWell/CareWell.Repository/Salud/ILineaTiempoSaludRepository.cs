using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;

namespace CareWell.Repository.Salud
{
    public interface ILineaTiempoSaludRepository : IRepository
    {
        List<EventoBaseDataView> ObtenerPorFechas(LineaTiempoSaludQuery query);
    }
}
