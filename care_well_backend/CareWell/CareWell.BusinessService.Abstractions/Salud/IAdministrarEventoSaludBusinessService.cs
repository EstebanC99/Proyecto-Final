using CareWell.Commands.Salud;
using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;

namespace CareWell.BusinessService.Abstractions.Salud
{
    public interface IAdministrarEventoSaludBusinessService
    {
        List<EventoSaludDataView> ObtenerTodos(EventoSaludQuery query);

        void Crear(CrearEventoSaludCommand command);
        void Eliminar(int eventoSaludID);
        void AgregarNota(CrearNotaEventoSaludCommand command);
        void ModificarNota(ModificarNotaEventoSaludCommand command);
        void EliminarNota(EliminarNotaEventoSaludCommand command);
    }
}
