using CareWell.Domain.ValueObjects.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

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
            if (string.IsNullOrEmpty(crearCuenta.Nombre))
                throw new ValidacionDominioException(Mensajes.NombreRequerido);

            if (string.IsNullOrEmpty(crearCuenta.Apellido))
                throw new ValidacionDominioException(Mensajes.ApellidoRequerido);

            if (string.IsNullOrEmpty(crearCuenta.Documento))
                throw new ValidacionDominioException(Mensajes.DocumentoRequerido);

            if (crearCuenta.FechaNacimiento == default)
                throw new ValidacionDominioException(Mensajes.FechaNacimientoRequerida);

            if (string.IsNullOrEmpty(crearCuenta.Email))
                throw new ValidacionDominioException(Mensajes.EmailRequerido);

            if (string.IsNullOrEmpty(crearCuenta.Telefono))
                throw new ValidacionDominioException(Mensajes.TelefonoRequerido);

            this.Nombre = crearCuenta.Nombre;
            this.Apellido = crearCuenta.Apellido;
            this.Documento = crearCuenta.Documento;
            this.FechaNacimiento = crearCuenta.FechaNacimiento;
            this.Email = crearCuenta.Email;
            this.Telefono = crearCuenta.Telefono;
        }

    }
}
