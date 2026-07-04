using CareWell.Commands.Salud;
using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;

namespace CareWell.BusinessService.Abstractions.Salud
{
    public interface IAdministrarHabitoVidaBusinessService
    {
        List<HabitoVidaDataView> ObtenerTodos(HabitoVidaQuery query);
        List<HabitoVidaRealizacionDataView> ObtenerRealizacionesPorFecha(HabitoVidaQuery query);
        void Crear(CrearHabitoVidaCommand command);
        void Modificar(ModificarHabitoVidaCommand command);
        void Eliminar(int habitoVidaID);
        void CrearRealizacion(CrearRealizacionHabitoVidaCommand command);
        void ModificarRealizacion(ModificarRealizacionHabitoVidaCommand command);
        void EliminarRealizacion(EliminarRealizacionHabitoVidaCommand command);
    }
}
