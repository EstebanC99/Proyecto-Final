namespace CareWell.Domain.General
{
    public class Persona : BaseEntity
    {
        public virtual string Nombre { get; private set; }

        public virtual string Apellido { get; private set; }

        public virtual string Documento { get; private set; }

        public virtual DateTime FechaNacimiento { get; private set; }

        public virtual string Email { get; private set; }

        public virtual string Telefono { get; private set; }

        public virtual string ImagenPath { get; private set; }
    }
}
