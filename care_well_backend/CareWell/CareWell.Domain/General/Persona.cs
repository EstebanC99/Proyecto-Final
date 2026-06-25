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

        public virtual void Crear(CrearPersona crearPersona)
        {
            if (string.IsNullOrEmpty(crearPersona.Nombre))
                throw new ValidacionDominioException(Mensajes.NombreRequerido);

            if (string.IsNullOrEmpty(crearPersona.Apellido))
                throw new ValidacionDominioException(Mensajes.ApellidoRequerido);

            if (string.IsNullOrEmpty(crearPersona.Documento))
                throw new ValidacionDominioException(Mensajes.DocumentoRequerido);

            if (crearPersona.FechaNacimiento == default)
                throw new ValidacionDominioException(Mensajes.FechaNacimientoRequerida);

            this.Nombre = crearPersona.Nombre;
            this.Apellido = crearPersona.Apellido;
            this.Documento = crearPersona.Documento;
            this.FechaNacimiento = crearPersona.FechaNacimiento;
            this.Email = crearPersona.Email;
            this.Telefono = crearPersona.Telefono;
        }

        public virtual void CrearDesdeCuenta(CrearPersona crearPersona)
        {
            if (string.IsNullOrEmpty(crearPersona.Email))
                throw new ValidacionDominioException(Mensajes.EmailRequerido);

            if (string.IsNullOrEmpty(crearPersona.Telefono))
                throw new ValidacionDominioException(Mensajes.TelefonoRequerido);

            this.Crear(crearPersona);
        }
    }
}
