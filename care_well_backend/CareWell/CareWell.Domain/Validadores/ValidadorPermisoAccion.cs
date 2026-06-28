using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;
using CareWell.Global.Constantes.EquipoCuidado;

namespace CareWell.Domain.Validadores
{
    public class ValidadorPermisoAccion : IValidadorPermisoAccion
    {
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }

        public ValidadorPermisoAccion(IEntityLoaderDomainService entityLoaderDomainService)
        {
            this.EntityLoaderDomainService = entityLoaderDomainService;
        }

        public bool PermiteModificarDatosPersonaCargo(AsignacionCuidado asignacionCuidado, Usuario usuarioModificador)
        {
            if (asignacionCuidado.Colaborador.ID != usuarioModificador.Persona.ID)
                return false;

            if (asignacionCuidado.Rol.ID != RolesCuidado.Responsable)
                return false;

            return true;
        }

        public bool PermiteAdministrarEquipoCuidado(Persona personaCuidada, Persona asignador)
        {
            var asignacionCuidado = this.EntityLoaderDomainService.Query<AsignacionCuidado>()
                .FirstOrDefault(a => a.PersonaCuidada.ID == personaCuidada.ID
                                  && a.Colaborador.ID == asignador.ID);

            if (asignacionCuidado is null)
                return false;

            if (!asignacionCuidado.Permisos.Any(p => p.ID == PermisosCuidado.AdministrarEquipo))
                return false;

            return true;
        }
    }
}
