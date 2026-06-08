using CareWell.Domain.Auth;
using CareWell.Domain.General;

namespace CareWell.Domain.Agenda
{
    public class EventoAgenda : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual Usuario UsuarioCreador { get; private set; }

        public virtual string Titulo { get; private set; }

        public virtual string? Descripcion { get; private set; }

        public virtual TipoEventoAgenda Tipo { get; private set; }

        public virtual DateTime FechaHoraInicio { get; private set; }

        public virtual DateTime? FechaHoraFin { get; private set; }
    }
}
