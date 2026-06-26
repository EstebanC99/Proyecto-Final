using CareWell.Domain.DomainServices;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
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

        public virtual DateTime? FechaEliminacion { get; set; }

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

            var permisos = entityLoaderDomainService.Query<PermisoCuidado>().ToList();
            this.Permisos.AddRange(permisos);
        }

        public virtual void ModificarInformacionPersona(ModificarInformacionPersona modificarAsignacionResponsable,
                                                        IValidadorPermisoAccion validadorPermisoAccion)
        {
            if (this.Estado.ID != EstadosAsignacionCuidado.Activa)
                throw new ValidacionDominioException(Mensajes.EstadoAsignacionNoPermiteEjecutarAccion);

            if (!validadorPermisoAccion.PermiteModificarDatosPersonaCargo(this, modificarAsignacionResponsable.UsuarioModificador))
                throw new ValidacionDominioException(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion);

            this.PersonaCuidada.CrearModificar(modificarAsignacionResponsable);
        }

        public virtual void Eliminar(IEntityLoaderDomainService entityLoaderDomainService)
        {
            this.Estado = entityLoaderDomainService.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Inactiva);

            this.FechaEliminacion = DateTime.UtcNow;
        }

        public virtual void Reactivar(IEntityLoaderDomainService entityLoaderDomainService)
        {
            if (!this.FechaEliminacion.HasValue) return;

            if (this.FechaEliminacion.Value < DateTime.UtcNow.AddDays(-30))
                throw new ValidacionDominioException(Mensajes.NoPuedeReactivarUnaAsignacionPasadoLos30Dias);

            this.Estado = entityLoaderDomainService.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Activa);
            this.FechaEliminacion = null;
        }
    }
}
