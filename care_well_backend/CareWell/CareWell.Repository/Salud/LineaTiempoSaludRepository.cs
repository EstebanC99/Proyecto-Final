using CareWell.DataViews.Salud;
using CareWell.Domain.Salud;
using CareWell.Queries.Salud;

namespace CareWell.Repository.Salud
{
    public class LineaTiempoSaludRepository : Repository, ILineaTiempoSaludRepository
    {
        public LineaTiempoSaludRepository(CareWellDbContext dbContext) : base(dbContext)
        {

        }

        public List<EventoBaseDataView> ObtenerPorFechas(LineaTiempoSaludQuery query)
        {
            var habitosRealizados = this.DbContext.Set<HabitoVidaRealizacion>()
                .Where(r => r.HabitoVida.Persona.ID == query.PersonaID
                         && r.FechaHoraRealizacion >= query.FechaDesde && r.FechaHoraRealizacion <= query.FechaHasta)
                .Select(r => new EventoBaseDataView
                {
                    ID = r.ID,
                    Descripcion = r.HabitoVida.Descripcion,
                    CategoriaEvento = "Hábito",
                    FechaHora = r.FechaHoraRealizacion
                })
                .ToList();

            var eventosSalud = this.DbContext.Set<EventoSalud>()
                .Where(e => e.Persona.ID == query.PersonaID
                         && e.FechaHora >= query.FechaDesde && e.FechaHora <= query.FechaHasta)
                .Select(e => new EventoBaseDataView
                {
                    ID = e.ID,
                    Descripcion = e.Descripcion,
                    CategoriaEvento = "Evento",
                    FechaHora = e.FechaHora
                })
                .ToList();


            var estadosAnimo = this.DbContext.Set<PersonaEstadoAnimo>()
                .Where(e => e.Persona.ID == query.PersonaID
                         && e.FechaHora >= query.FechaDesde && e.FechaHora <= query.FechaHasta)
                .Select(e => new EventoBaseDataView
                {
                    ID = e.ID,
                    Descripcion = e.EstadoAnimo.Descripcion,
                    CategoriaEvento = "Ánimo",
                    FechaHora = e.FechaHora
                })
                .ToList();

            List<EventoBaseDataView> eventos = [.. habitosRealizados, .. eventosSalud, .. estadosAnimo];

            return eventos.OrderBy(e => e.FechaHora).ToList();
        }
    }
}
