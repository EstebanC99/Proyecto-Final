using CareWell.DataViews.Salud;
using CareWell.Domain.Salud;
using CareWell.Queries.Salud;

namespace CareWell.Repository.Salud
{
    public interface IPersonaEstadoAnimoRepository : IRepository<PersonaEstadoAnimo>
    {
        PersonaEstadoAnimoDataView ObtenerAnimoHoy(PersonaEstadoAnimoHoyQuery query);
        List<PersonaEstadoAnimoDataView> ObtenerPorFechas(PersonaEstadoAnimoPorFechaQuery query);
        List<PersonaEstadoAnimo> GetByFechas(int personaID, DateTime fechaDesde, DateTime fechaHasta);
    }
}