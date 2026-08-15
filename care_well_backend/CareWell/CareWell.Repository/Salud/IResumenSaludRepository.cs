using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;

namespace CareWell.Repository.Salud
{
    public interface IResumenSaludRepository : IRepository
    {
        ResumenSaludDataView Obtener(ResumenSaludQuery query);
    }
}