using CareWell.Domain.Agenda;
using CareWell.Domain.General;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Salud
{
    public class EventoSalud : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual TipoEvento Tipo { get; private set; }

        public virtual DateTime FechaHora { get; private set; }

        public virtual string Descripcion { get; private set; }

        public virtual List<NotaEventoSalud> Notas { get; private set; }

        public virtual EventoAgenda? EventoAgenda { get; private set; }

        public virtual DateTime? FechaOcurrenciaEventoAgenda { get; private set; }

        public EventoSalud()
        {
            this.Notas = new List<NotaEventoSalud>();
        }

        public virtual void GenerarDesdeAgenda(EventoAgenda eventoAgenda, DateTime fechaOcurrencia)
        {
            if (eventoAgenda is null)
                throw new ValidacionDominioException(Mensajes.ElEventoAgendaEsRequeridoParaElEventoSalud);

            if (!eventoAgenda.GenerarEventoSalud)
                throw new ValidacionDominioException(Mensajes.ElEventoAgendaNoGeneraEventoSalud);

            this.Persona = eventoAgenda.Persona;
            this.Tipo = eventoAgenda.Tipo;
            this.FechaHora = fechaOcurrencia;
            this.Descripcion = eventoAgenda.Titulo;
            this.EventoAgenda = eventoAgenda;
            this.FechaOcurrenciaEventoAgenda = fechaOcurrencia;
        }
    }
}
