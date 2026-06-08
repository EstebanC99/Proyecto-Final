using CareWell.Domain.General;

namespace CareWell.Domain.Salud
{
    public class EventoSalud : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual TipoEventoSalud Tipo { get; private set; }

        public virtual DateTime FechaHora { get; private set; }

        public virtual string Descripcion { get; private set; }

        public virtual List<NotaEventoSalud> Notas { get; private set; }
    }
}
