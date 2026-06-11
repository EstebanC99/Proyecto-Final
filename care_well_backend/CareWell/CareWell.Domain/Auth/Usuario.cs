using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.General;
using CareWell.Global.Constantes.Auth;

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
            this.Persona = persona;
            this.NombreUsuario = email;
            this.ContrasenaHash = passwordHasherDomainService.Hashear(contrasena);
            this.Estado = entityLoaderDomainService.GetByID<EstadoUsuario>(EstadosUsuario.Activo);
        }
    }
}
