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

        public virtual void Asignar(CrearAsignacion crearAsignacion,
                                    IEntityLoaderDomainService entityLoaderDomainService,
                                    IValidadorPermisoAccion validadorPermisoAccion)
        {
            if (!validadorPermisoAccion.PermiteAdministrarEquipoCuidado(crearAsignacion.PersonaCuidada, crearAsignacion.Asignador))
                throw new ValidacionDominioException(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion);

            if (crearAsignacion.PersonaCuidada is null)
                throw new ValidacionDominioException(Mensajes.PersonaNoExiste);

            if (crearAsignacion.Colaborador is null)
                throw new ValidacionDominioException(Mensajes.PersonaColaboradorRequerido);

            if (crearAsignacion.Rol is null)
                throw new ValidacionDominioException(Mensajes.RolCuidadoRequerido);

            if (crearAsignacion.Permisos.Count == default)
                throw new ValidacionDominioException(Mensajes.DebeSeleccionarUnoMasPermisos);

            this.PersonaCuidada = crearAsignacion.PersonaCuidada;
            this.Colaborador = crearAsignacion.Colaborador;
            this.Rol = crearAsignacion.Rol;

            this.Estado = entityLoaderDomainService.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Pendiente);
            this.FechaAlta = DateTime.Now;

            this.Permisos.AddRange(crearAsignacion.Permisos);
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
            this.FechaAlta = DateTime.Now;

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

            this.FechaEliminacion = DateTime.Now;
        }

        public virtual void Activar(IEntityLoaderDomainService entityLoaderDomainService)
        {
            if (this.Estado.ID != EstadosAsignacionCuidado.Pendiente)
                throw new ValidacionDominioException(Mensajes.NoSePuedeActivarUnaAsignacionConEstadoDiferentePendiente);

            this.Estado = entityLoaderDomainService.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Activa);
        }

        public virtual void Reactivar(IEntityLoaderDomainService entityLoaderDomainService)
        {
            if (!this.FechaEliminacion.HasValue) return;

            if (this.FechaEliminacion.Value < DateTime.Now.AddDays(-30))
                throw new ValidacionDominioException(Mensajes.NoPuedeReactivarUnaAsignacionPasadoLos30Dias);

            this.Estado = entityLoaderDomainService.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Activa);
            this.FechaEliminacion = null;
        }

        public virtual void ModificarPermisos(ModificarPermisosAsignacion modificarPermisos,
                                              IValidadorPermisoAccion validadorPermisoAccion)
        {
            if (this.Estado.ID != EstadosAsignacionCuidado.Activa)
                throw new ValidacionDominioException(Mensajes.EstadoAsignacionNoPermiteEjecutarAccion);

            if (!validadorPermisoAccion.PermiteAdministrarEquipoCuidado(this.PersonaCuidada, modificarPermisos.Asignador))
                throw new ValidacionDominioException(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion);

            foreach (var permisoAsignado in modificarPermisos.NuevosPermisos)
            {
                if (!this.Permisos.Any(p => p.ID == permisoAsignado.ID))
                    this.Permisos.Add(permisoAsignado);
            }

            foreach (var permisoExistente in this.Permisos)
            {
                if (!modificarPermisos.NuevosPermisos.Any(p => p.ID == permisoExistente.ID))
                    this.Permisos.Remove(permisoExistente);
            }
        }
    }
}
