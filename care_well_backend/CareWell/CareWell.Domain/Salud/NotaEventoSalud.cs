using CareWell.Domain.General;

namespace CareWell.Domain.Salud
{
    public class NotaEventoSalud : BaseEntity
    {
        public virtual Persona Autor { get; private set; }

        public virtual DateTime FechaHora { get; private set; }

        public virtual string Contenido { get; private set; }

        public virtual EventoSalud EventoSalud { get; private set; }
    }
}
