using CareWell.Domain.General;

namespace CareWell.Domain.Emergencias
{
    public class Emergencia : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual DateTime FechaHora { get; private set; }

        public virtual bool Atendida { get; private set; }

        public virtual string? Descripcion { get; private set; }
    }
}
