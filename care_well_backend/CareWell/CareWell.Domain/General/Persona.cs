using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.Validadores;
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

        public virtual byte[]? Imagen { get; private set; }

        public virtual bool IdentidadValidada { get; private set; }

        public virtual DateTime? FechaValidacionIdentidad { get; private set; }

        public virtual void CrearDesdeCuenta(CrearModificarPersona crearPersona)
        {
            if (string.IsNullOrEmpty(crearPersona.Email))
                throw new ValidacionDominioException(Mensajes.EmailRequerido);

            if (string.IsNullOrEmpty(crearPersona.Telefono))
                throw new ValidacionDominioException(Mensajes.TelefonoRequerido);

            this.CrearModificar(crearPersona);
        }

        public virtual void CrearModificar(CrearModificarPersona crearModificarPersona)
        {
            this.SetearCamposPerfil(crearModificarPersona);

            this.Email = crearModificarPersona.Email;
        }

        public virtual void ModificarPerfil(ModificarPerfil modificarPerfil,
                                            Persona colaborador,
                                            IValidadorPermisoAccion validadorPermisoAccion)
        {
            validadorPermisoAccion.ValidarPuedeModificarPerfil(this, colaborador);

            this.SetearCamposPerfil(modificarPerfil);
        }

        public virtual void ValidarIdentidad(TextoDocumentoReconocido textoDocumentoReconocido)
        {
            var esIdentidadCorrecta =
                this.Documento == textoDocumentoReconocido.NumeroDocumento &&
                this.Nombre.Equals(textoDocumentoReconocido.Nombre, StringComparison.CurrentCultureIgnoreCase) &&
                this.Apellido.Equals(textoDocumentoReconocido.Apellido, StringComparison.CurrentCultureIgnoreCase);

            if (esIdentidadCorrecta)
            {
                this.IdentidadValidada = true;
                this.FechaValidacionIdentidad = DateTime.Now;
            }
        }

        public virtual void ValidarCrearUsuario(IEntityLoaderDomainService entityLoaderDomainService)
        {
            var tieneUsuario = entityLoaderDomainService.Query<Usuario>().Any(u => u.Persona.ID == this.ID);

            if (tieneUsuario)
                throw new CuentaExistenteException(Mensajes.PersonaYaTieneUsuario);
        }

        public virtual string NombreCompleto()
        {
            return $"{this.Nombre} {this.Apellido}";
        }

        #region Metodos Privados

        private void SetearCamposPerfil(ModificarPerfil modificarPerfil)
        {
            if (string.IsNullOrEmpty(modificarPerfil.Nombre))
                throw new ValidacionDominioException(Mensajes.NombreRequerido);

            if (string.IsNullOrEmpty(modificarPerfil.Apellido))
                throw new ValidacionDominioException(Mensajes.ApellidoRequerido);

            if (string.IsNullOrEmpty(modificarPerfil.Documento))
                throw new ValidacionDominioException(Mensajes.DocumentoRequerido);

            if (modificarPerfil.FechaNacimiento == default)
                throw new ValidacionDominioException(Mensajes.FechaNacimientoRequerida);

            this.Nombre = modificarPerfil.Nombre;
            this.Apellido = modificarPerfil.Apellido;
            this.Documento = modificarPerfil.Documento;
            this.FechaNacimiento = modificarPerfil.FechaNacimiento;
            this.Telefono = modificarPerfil.Telefono;
            this.Imagen = modificarPerfil.Imagen;
        }

        #endregion
    }
}
