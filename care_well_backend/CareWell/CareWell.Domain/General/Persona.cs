using CareWell.Domain.ValueObjects.General;
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

        public virtual string? Email { get; private set; }

        public virtual string? Telefono { get; private set; }

        public virtual string? ImagenPath { get; private set; }

        public virtual void CrearModificar(CrearModificarPersona crearModificarPersona)
        {
            if (string.IsNullOrEmpty(crearModificarPersona.Nombre))
                throw new ValidacionDominioException(Mensajes.NombreRequerido);

            if (string.IsNullOrEmpty(crearModificarPersona.Apellido))
                throw new ValidacionDominioException(Mensajes.ApellidoRequerido);

            if (string.IsNullOrEmpty(crearModificarPersona.Documento))
                throw new ValidacionDominioException(Mensajes.DocumentoRequerido);

            if (crearModificarPersona.FechaNacimiento == default)
                throw new ValidacionDominioException(Mensajes.FechaNacimientoRequerida);

            this.Nombre = crearModificarPersona.Nombre;
            this.Apellido = crearModificarPersona.Apellido;
            this.Documento = crearModificarPersona.Documento;
            this.FechaNacimiento = crearModificarPersona.FechaNacimiento;
            this.Email = crearModificarPersona.Email;
            this.Telefono = crearModificarPersona.Telefono;
        }

        public virtual void CrearDesdeCuenta(CrearModificarPersona crearPersona)
        {
            if (string.IsNullOrEmpty(crearPersona.Email))
                throw new ValidacionDominioException(Mensajes.EmailRequerido);

            if (string.IsNullOrEmpty(crearPersona.Telefono))
                throw new ValidacionDominioException(Mensajes.TelefonoRequerido);

            this.CrearModificar(crearPersona);
        }
    }
}
