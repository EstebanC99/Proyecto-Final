using CareWell.DataViews;
using CareWell.DataViews.General;
using CareWell.DataViews.Salud;
using CareWell.Domain.Salud;
using CareWell.Queries.Salud;

namespace CareWell.Repository.Salud
{
    public class EventoSaludRepository : Repository<EventoSalud>, IEventoSaludRepository
    {
        public EventoSaludRepository(CareWellDbContext dbContext) : base(dbContext)
        {

        }

        public List<EventoSaludDataView> ObtenerTodos(EventoSaludQuery query)
        {
            return this.DbSet
                .Where(e => e.Persona.ID == query.PersonaID
                         && e.FechaHora >= query.FechaDesde
                         && e.FechaHora <= query.FechaHasta)
                .ToList()
                .Select(MapToDataView)
                .ToList();
        }

        public bool ExistePorOrigen(int eventoAgendaID, DateTime fechaOcurrencia)
        {
            return this.DbSet
                .Any(e => e.EventoAgenda != null
                       && e.EventoAgenda.ID == eventoAgendaID
                       && e.FechaOcurrenciaEventoAgenda == fechaOcurrencia);
        }

        #region Metodos Privados

        private static EventoSaludDataView MapToDataView(EventoSalud eventoSalud)
        {
            return new EventoSaludDataView
            {
                ID = eventoSalud.ID,
                Persona = new BaseEntityDataView
                {
                    ID = eventoSalud.Persona.ID,
                    Descripcion = eventoSalud.Persona.Nombre + ' ' + eventoSalud.Persona.Apellido
                },
                Tipo = new TipoEventoDataView
                {
                    ID = eventoSalud.Tipo.ID,
                    Descripcion = eventoSalud.Tipo.Descripcion,
                    Agendable = eventoSalud.Tipo.Agendable
                },
                FechaHora = eventoSalud.FechaHora,
                Descripcion = eventoSalud.Descripcion,
                Notas = eventoSalud.Notas.Select(n => new NotaEventoSaludDataView
                {
                    ID = n.ID,
                    Autor = new BaseEntityDataView
                    {
                        ID = n.Autor.ID,
                        Descripcion = n.Autor.Nombre + ' ' + n.Autor.Apellido,
                    },
                    FechaHora = n.FechaHora,
                    Contenido = n.Contenido,
                }).ToList(),
            };
        }

        #endregion
    }
}
