using CareWell.Domain.ValueObjects.Auth;

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

        public virtual string? ImagenPath { get; private set; }
        
        public virtual void Crear(CrearCuenta crearCuenta)
        {
            this.Nombre = crearCuenta.Nombre;
            this.Apellido = crearCuenta.Apellido;
            this.Documento = crearCuenta.Documento;
            this.FechaNacimiento = crearCuenta.FechaNacimiento;
            this.Email = crearCuenta.Email;
            this.Telefono = crearCuenta.Telefono;
        }

    }
}
