using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.General;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Auth
{
    public class Usuario : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual string NombreUsuario { get; private set; }

        public virtual string ContrasenaHash { get; private set; }

        public virtual EstadoUsuario Estado { get; private set; }

        public virtual void Crear(Persona persona,
                                  string email,
                                  string contrasena,
                                  IEntityLoaderDomainService entityLoaderDomainService,
                                  IPasswordHasherDomainService passwordHasherDomainService)
        {
            if (persona is null)
                throw new ValidacionDominioException(Mensajes.PersonaNoExiste);

            if (string.IsNullOrEmpty(email))
                throw new ValidacionDominioException(Mensajes.EmailRequerido);

            if (string.IsNullOrEmpty(contrasena))
                throw new ValidacionDominioException(Mensajes.ContrasenaRequerida);

            if (entityLoaderDomainService.Query<Usuario>().Any(u => u.NombreUsuario == email))
                throw new ValidacionDominioException(Mensajes.NombreUsuarioEnUso);

            this.Persona = persona;
            this.NombreUsuario = email;
            this.ContrasenaHash = passwordHasherDomainService.Hashear(contrasena);
            this.Estado = entityLoaderDomainService.GetByID<EstadoUsuario>(EstadosUsuario.Activo);
        }
    }
}
