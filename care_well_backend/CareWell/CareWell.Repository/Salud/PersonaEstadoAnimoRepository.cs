using CareWell.DataViews.Salud;
using CareWell.Domain.Salud;
using CareWell.Queries.Salud;

namespace CareWell.Repository.Salud
{
    public class PersonaEstadoAnimoRepository : Repository<PersonaEstadoAnimo>, IPersonaEstadoAnimoRepository
    {
        public PersonaEstadoAnimoRepository(CareWellDbContext dbContext) : base(dbContext)
        {

        }

        public PersonaEstadoAnimoDataView ObtenerAnimoHoy(PersonaEstadoAnimoHoyQuery query)
        {
            return this.DbSet
                .Where(a => a.Persona.ID == query.PersonaID
                         && a.FechaHora.Date == DateTime.Today)
                .OrderByDescending(a => a.FechaHora).Take(1)
                .ToList()
                .Select(MapToDataView)
                .FirstOrDefault();
        }

        public List<PersonaEstadoAnimoDataView> ObtenerPorFechas(PersonaEstadoAnimoPorFechaQuery query)
        {
            return this.DbSet
                .Where(a => a.Persona.ID == query.PersonaID
                         && a.FechaHora >= query.FechaDesde
                         && a.FechaHora <= query.FechaHasta)
                .ToList()
                .Select(MapToDataView)
                .ToList();
        }

        #region Metodos Privados

        private static PersonaEstadoAnimoDataView MapToDataView(PersonaEstadoAnimo animo)
        {
            return new PersonaEstadoAnimoDataView
            {
                ID = animo.ID,
                EstadoAnimo = new DataViews.BaseEntityDataView
                {
                    ID = animo.EstadoAnimo.ID,
                    Descripcion = animo.EstadoAnimo.Descripcion
                },
                FechaHora = animo.FechaHora,
                Observaciones = animo.Observaciones
            };
        }

        #endregion
    }
}
