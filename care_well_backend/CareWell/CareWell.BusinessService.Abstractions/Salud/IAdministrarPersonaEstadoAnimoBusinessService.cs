using CareWell.Commands.Salud;
using CareWell.DataViews.Salud;
using CareWell.Queries.Salud;

namespace CareWell.BusinessService.Abstractions.Salud
{
    public interface IAdministrarPersonaEstadoAnimoBusinessService
    {
        PersonaEstadoAnimoDataView ObtenerAnimoHoy(PersonaEstadoAnimoHoyQuery query);
        List<PersonaEstadoAnimoDataView> ObtenerPorFechas(PersonaEstadoAnimoPorFechaQuery query);

        void Registrar(RegistrarEstadoAnimoCommand command);
    }
}
