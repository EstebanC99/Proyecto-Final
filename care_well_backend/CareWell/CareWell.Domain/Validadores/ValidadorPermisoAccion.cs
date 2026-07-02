using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;
using CareWell.Global.Constantes.EquipoCuidado;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Validadores
{
    public class ValidadorPermisoAccion : IValidadorPermisoAccion
    {
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }

        public ValidadorPermisoAccion(IEntityLoaderDomainService entityLoaderDomainService)
        {
            this.EntityLoaderDomainService = entityLoaderDomainService;
        }

        public void ValidarPuedeModificarDatosPersonaCargo(AsignacionCuidado asignacionCuidado, Usuario usuarioModificador)
        {
            if (asignacionCuidado.Colaborador.ID != usuarioModificador.Persona.ID || asignacionCuidado.Rol.ID != RolesCuidado.Responsable)
                throw new ValidacionDominioException(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion);
        }

        public void ValidarPuedeAdministrarEquipoCuidado(Persona personaCuidada, Persona asignador)
        {
            this.ValidarAccionSobrePersona(personaCuidada, asignador, PermisosCuidado.AdministrarEquipo);
        }

        public void ValidarPuedeAdministrarAgenda(Persona personaCuidada, Persona solicitante)
        {
            this.ValidarAccionSobrePersona(personaCuidada, solicitante, PermisosCuidado.GestionarAgenda);
        }

        public void ValidarVisualizacion(Persona personaCuidada, Persona solicitante)
        {
            if (personaCuidada.ID == solicitante.ID)
                return;

            var asignacionCuidado = this.ObtenerAsignacionCuidadoActiva(personaCuidada, solicitante);

            if (asignacionCuidado is null)
                throw new ValidacionDominioException(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion);
        }

        #region Metodos Privados

        private void ValidarAccionSobrePersona(Persona personaSeleccionada, Persona solicitante, int permisoCuidadoID)
        {
            if (personaSeleccionada.ID == solicitante.ID)
                return;

            var asignacionCuidado = this.ObtenerAsignacionCuidadoActiva(personaSeleccionada, solicitante);

            if (asignacionCuidado is null || !asignacionCuidado.Permisos.Any(p => p.ID == permisoCuidadoID))
                throw new ValidacionDominioException(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion);
        }

        private AsignacionCuidado? ObtenerAsignacionCuidadoActiva(Persona personaSeleccionada, Persona solicitante)
        {
            return this.EntityLoaderDomainService.Query<AsignacionCuidado>()
                .FirstOrDefault(a => a.PersonaCuidada.ID == personaSeleccionada.ID
                                  && a.Colaborador.ID == solicitante.ID
                                  && a.Estado.ID == EstadosAsignacionCuidado.Activa);
        }

        #endregion
    }
}
