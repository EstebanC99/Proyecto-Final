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

        public virtual DateTime? FechaEliminacion { get; private set; }

        public virtual List<PermisoCuidado> Permisos { get; private set; }

        public AsignacionCuidado()
        {
            this.Permisos = new List<PermisoCuidado>();
        }

        public virtual void Asignar(CrearAsignacion crearAsignacion,
                                    IEntityLoaderDomainService entityLoaderDomainService,
                                    IValidadorPermisoAccion validadorPermisoAccion,
                                    IValidarExistenciaAsignacionCuidado validarExistenciaAsignacionCuidado)
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

            if (validarExistenciaAsignacionCuidado.ExisteAsignacionColaboradorElegido(crearAsignacion.PersonaCuidada, crearAsignacion.Colaborador))
                throw new ValidacionDominioException(Mensajes.YaExisteUnaAsignacionRegistradaParaElColaboradorSeleccionado);

            this.PersonaCuidada = crearAsignacion.PersonaCuidada;
            this.Colaborador = crearAsignacion.Colaborador;
            this.Rol = crearAsignacion.Rol;

            this.Estado = entityLoaderDomainService.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Pendiente);
            this.FechaAlta = DateTime.Now;
            this.FechaEliminacion = null;

            this.ActualizarPermisos(crearAsignacion.Permisos);
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

        public virtual void Reactivar(Persona reactivador, 
                                      IEntityLoaderDomainService entityLoaderDomainService)
        {
            if (!this.FechaEliminacion.HasValue) return;

            if (this.FechaEliminacion.Value < DateTime.Now.AddDays(-30))
                throw new ValidacionDominioException(Mensajes.NoPuedeReactivarUnaAsignacionPasadoLos30Dias);

            if (reactivador.ID == this.Colaborador.ID)
                this.Estado = entityLoaderDomainService.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Activa);
            else
                this.Estado = entityLoaderDomainService.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Pendiente);

            this.FechaEliminacion = null;
        }

        public virtual void ModificarPermisos(ModificarPermisosAsignacion modificarPermisos,
                                              IValidadorPermisoAccion validadorPermisoAccion)
        {
            if (this.Estado.ID != EstadosAsignacionCuidado.Activa)
                throw new ValidacionDominioException(Mensajes.EstadoAsignacionNoPermiteEjecutarAccion);

            if (!validadorPermisoAccion.PermiteAdministrarEquipoCuidado(this.PersonaCuidada, modificarPermisos.Asignador))
                throw new ValidacionDominioException(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion);

            this.ActualizarPermisos(modificarPermisos.NuevosPermisos);
        }

        #region Metodos Privados

        private void ActualizarPermisos(List<PermisoCuidado> permisosSeleccionados)
        {
            var permisosAgregar = permisosSeleccionados.Where(permisoNuevo => !this.Permisos.Select(p => p.ID).Contains(permisoNuevo.ID)).ToList();
            this.Permisos.AddRange(permisosAgregar);

            var permisosEliminar = this.Permisos.Where(permisoExistente => !permisosSeleccionados.Select(p => p.ID).Contains(permisoExistente.ID)).ToList();
            permisosEliminar.ForEach(p => this.Permisos.Remove(p));
        }

        #endregion
    }
}
