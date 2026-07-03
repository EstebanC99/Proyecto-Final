using CareWell.DataViews.General;
using CareWell.Domain.General;

namespace CareWell.Repository.General
{
    public interface ITipoEventoRepository : IRepository<TipoEvento>
    {
        List<TipoEventoDataView> ObtenerTodos();
    }
}