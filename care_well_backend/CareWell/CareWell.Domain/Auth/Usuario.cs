using CareWell.Domain.General;

namespace CareWell.Domain.Auth
{
    public class Usuario : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual string NombreUsuario { get; private set; }

        public virtual string ContrasenaHash { get; private set; }

        public virtual EstadoUsuario Estado { get; private set; }
    }
}
