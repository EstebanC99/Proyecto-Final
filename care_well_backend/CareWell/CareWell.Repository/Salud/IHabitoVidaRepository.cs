using CareWell.DataViews.Salud;
using CareWell.Domain.Salud;
using CareWell.Queries.Salud;

namespace CareWell.Repository.Salud
{
    public interface IHabitoVidaRepository : IRepository<HabitoVida>
    {
        List<HabitoVidaDataView> ObtenerTodos(HabitoVidaQuery query);
        List<HabitoVidaRealizacionDataView> ObtenerRealizacionesPorFecha(HabitoVidaQuery query);
    }
}