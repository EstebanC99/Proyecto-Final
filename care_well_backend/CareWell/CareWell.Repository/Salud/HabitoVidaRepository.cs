using CareWell.DataViews;
using CareWell.DataViews.Salud;
using CareWell.Domain.Salud;
using CareWell.Queries.Salud;

namespace CareWell.Repository.Salud
{
    public class HabitoVidaRepository : Repository<HabitoVida>, IHabitoVidaRepository
    {
        public HabitoVidaRepository(CareWellDbContext careWellDbContext) : base(careWellDbContext)
        {

        }

        public List<HabitoVidaDataView> ObtenerTodos(HabitoVidaQuery query)
        {
            return this.DbSet
                .Where(h => h.Persona.ID == query.PersonaID
                         && h.Activo)
                .ToList()
                .Select(h => new HabitoVidaDataView
                {
                    ID = h.ID,
                    Persona = new BaseEntityDataView
                    {
                        ID = h.Persona.ID,
                        Descripcion = h.Persona.Nombre + ' ' + h.Persona.Apellido
                    },
                    Tipo = new BaseEntityDataView
                    {
                        ID = h.Tipo.ID,
                        Descripcion = h.Tipo.Descripcion
                    },
                    Descripcion = h.Descripcion,
                    Activo = h.Activo,
                    Realizacion = h.Realizaciones
                        .Where(r => r.FechaHoraRealizacion.Date == DateTime.Today)
                        .Select(MapRealizacionToDataView)
                        .FirstOrDefault()
                }).ToList();
        }

        public List<HabitoVidaRealizacionDataView> ObtenerRealizacionesPorFecha(HabitoVidaQuery query)
        {
            return this.DbContext.Set<HabitoVidaRealizacion>()
                .Where(r => r.HabitoVida.Persona.ID == query.PersonaID
                         && r.FechaHoraRealizacion >= query.FechaDesde
                         && r.FechaHoraRealizacion <= query.FechaHasta)
                .Select(MapRealizacionToDataView)
                .ToList();
        }

        public List<HabitoVida> GetByPersona(int personaCuidadaID)
        {
            return this.DbSet
                .Where(h => 
                    h.Persona.ID == personaCuidadaID &&
                    h.Activo)
                .ToList();
        }

        #region Metodos Privados

        private static HabitoVidaRealizacionDataView MapRealizacionToDataView(HabitoVidaRealizacion realizacion)
        {
            return new HabitoVidaRealizacionDataView
            {
                ID = realizacion.ID,
                HabitoVidaID = realizacion.HabitoVida.ID,
                Descripcion = realizacion.HabitoVida.Descripcion,
                Comentarios = realizacion.Comentarios,
                FechaHoraRealizacion = realizacion.FechaHoraRealizacion
            };
        }

        #endregion
    }
}
