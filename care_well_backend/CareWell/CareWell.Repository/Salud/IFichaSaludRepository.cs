using CareWell.DataViews.Salud;
using CareWell.Domain.Salud;
using CareWell.Queries.Salud;

namespace CareWell.Repository.Salud
{
    public interface IFichaSaludRepository : IRepository<FichaSalud>
    {
        FichaSaludDataView Obtener(FichaSaludQuery query);
    }
}