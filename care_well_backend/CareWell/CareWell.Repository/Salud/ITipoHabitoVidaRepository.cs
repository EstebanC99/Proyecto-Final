using CareWell.DataViews;
using CareWell.Domain.Salud;

namespace CareWell.Repository.Salud
{
    public interface ITipoHabitoVidaRepository : IRepository<TipoHabitoVida>
    {
        List<BaseEntityDataView> ObtenerTodos();
    }
}