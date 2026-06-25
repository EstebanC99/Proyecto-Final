using CareWell.Domain.DomainServices;
using CareWell.Domain.General;
using CareWell.Domain.ValueObjects.EquipoCuidado;
using CareWell.Global.Constantes.EquipoCuidado;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.EquipoCuidado
{
    public class AsignacionCuidado : BaseEntity
    {
        public virtual Persona PersonaCuidada { get; private set; }

        public virtual Persona Colaborador { get; private set; }

        public virtual RolCuidado Rol { get; private set; }

        public virtual EstadoAsignacionCuidado Estado { get; private set; }

        public virtual DateTime FechaAlta { get; private set; }

        public virtual List<PermisoCuidado> Permisos { get; private set; }

        public AsignacionCuidado()
        {
            this.Permisos = new List<PermisoCuidado>();
        }

        public virtual void AsignarResponsable(CrearAsignacionResponsable crearPersonaCargo,
                                               IEntityLoaderDomainService entityLoaderDomainService)
        {
            if (crearPersonaCargo.PersonaCuidada is null)
                throw new ValidacionDominioException(Mensajes.PersonaNoExiste);

            if (crearPersonaCargo.UsuarioCreador?.Persona is null)
                throw new ValidacionDominioException(Mensajes.ColaboradorRequerido);

            this.PersonaCuidada = crearPersonaCargo.PersonaCuidada;
            this.Colaborador = crearPersonaCargo.UsuarioCreador.Persona;

            this.Rol = entityLoaderDomainService.GetByID<RolCuidado>(RolesCuidado.Responsable);
            this.Estado = entityLoaderDomainService.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Activa);
            this.FechaAlta = DateTime.UtcNow;
        }

        public virtual void AsignarPermisosResponsable(IEntityLoaderDomainService entityLoaderDomainService)
        {
            var permisos = entityLoaderDomainService.Query<PermisoCuidado>().ToList();
            this.Permisos.AddRange(permisos);
        }
    }
}
