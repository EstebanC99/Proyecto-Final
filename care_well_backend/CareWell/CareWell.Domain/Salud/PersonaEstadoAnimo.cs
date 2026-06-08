using CareWell.Domain.General;

namespace CareWell.Domain.Salud
{
    public class PersonaEstadoAnimo : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual EventoSalud? EventoSalud { get; private set; }

        public virtual DateTime FechaHora { get; private set; }

        public virtual EstadoAnimo EstadoAnimo { get; private set; }

        public virtual string? Observaciones { get; private set; }
    }
}
