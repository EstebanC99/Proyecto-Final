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

        public void ValidarPuedeAdministrarEquipoCuidado(Persona personaCuidada, Persona colaborador)
        {
            this.ValidarAccionSobrePersona(personaCuidada, colaborador, PermisosCuidado.AdministrarEquipo);
        }

        public void ValidarPuedeAdministrarAgenda(Persona personaCuidada, Persona colaborador)
        {
            this.ValidarAccionSobrePersona(personaCuidada, colaborador, PermisosCuidado.GestionarAgenda);
        }

        public void ValidarPuedeAdministrarEventosSalud(Persona personaCuidada, Persona colaborador)
        {
            this.ValidarAccionSobrePersona(personaCuidada, colaborador, PermisosCuidado.RegistrarEventosSalud);
        }

        public void ValidarPuedeRegistrarHabitos(Persona personaCuidada, Persona colaborador)
        {
            this.ValidarAccionSobrePersona(personaCuidada, colaborador, PermisosCuidado.RegistrarHabitos);
        }

        public void ValidarPuedeAdministrarFichaSalud(Persona personaCuidada, Persona colaborador)
        {
            this.ValidarAccionSobrePersona(personaCuidada, colaborador, PermisosCuidado.EditarFichaSalud);
        }

        public void ValidarPuedeVerFichaSalud(Persona personaCuidada, Persona colaborador)
        {
            this.ValidarAccionSobrePersona(personaCuidada, colaborador, PermisosCuidado.VerFichaSalud);
        }

        public void ValidarVisualizacion(Persona personaCuidada, Persona colaborador)
        {
            if (personaCuidada.ID == colaborador.ID)
                return;

            var asignacionCuidado = this.ObtenerAsignacionCuidadoActiva(personaCuidada, colaborador);

            if (asignacionCuidado is null)
                throw new ValidacionDominioException(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion);
        }

        public void ValidarPuedeModificarPerfil(Persona personaCuidada, Persona colaborador)
        {
            if (personaCuidada.ID != colaborador.ID)
                throw new ValidacionDominioException(Mensajes.ElPerfilSeleccionadoNoCorrespondeAlPropio);
        }

        #region Metodos Privados

        private void ValidarAccionSobrePersona(Persona personaSeleccionada, Persona colaborador, int permisoCuidadoID)
        {
            if (personaSeleccionada.ID == colaborador.ID)
                return;

            var asignacionCuidado = this.ObtenerAsignacionCuidadoActiva(personaSeleccionada, colaborador);

            if (asignacionCuidado is null || !asignacionCuidado.Permisos.Any(p => p.ID == permisoCuidadoID))
                throw new ValidacionDominioException(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion);
        }

        private AsignacionCuidado? ObtenerAsignacionCuidadoActiva(Persona personaSeleccionada, Persona colaborador)
        {
            return this.EntityLoaderDomainService.Query<AsignacionCuidado>()
                .FirstOrDefault(a => a.PersonaCuidada.ID == personaSeleccionada.ID
                                  && a.Colaborador.ID == colaborador.ID
                                  && a.Estado.ID == EstadosAsignacionCuidado.Activa);
        }

        #endregion
    }
}
