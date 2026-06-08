using CareWell.Domain.General;

namespace CareWell.Domain.Salud
{
    public class FichaSalud : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual string? Antecedentes { get; private set; }

        public virtual string? Estudios { get; private set; }
    }
}
