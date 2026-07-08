using CareWell.Commands.Salud;
using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;

namespace CareWell.BusinessService.Abstractions.Salud
{
    public interface IAdministrarFichaSaludBusinessService
    {
        FichaSaludDataView Obtener(FichaSaludQuery query);

        void Crear(CrearFichaSaludCommand command);
        void Modificar(ModificarFichaSaludCommand command);
    }
}
