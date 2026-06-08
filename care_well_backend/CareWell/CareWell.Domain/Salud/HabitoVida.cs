using CareWell.Domain.General;

namespace CareWell.Domain.Salud
{
    public class HabitoVida : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual TipoHabitoVida Tipo { get; private set; }

        public virtual string Descripcion { get; private set; }
    }
}
