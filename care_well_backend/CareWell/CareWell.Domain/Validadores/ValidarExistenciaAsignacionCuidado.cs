using CareWell.Domain.DomainServices;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;
using CareWell.Global.Constantes.EquipoCuidado;

namespace CareWell.Domain.Validadores
{
    public class ValidarExistenciaAsignacionCuidado : IValidarExistenciaAsignacionCuidado
    {
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }

        public ValidarExistenciaAsignacionCuidado(IEntityLoaderDomainService entityLoaderDomainService)
        {
            this.EntityLoaderDomainService = entityLoaderDomainService;
        }

        public bool ExisteAsignacionColaboradorElegido(Persona personaCuidada, Persona colaborador)
        {
            if (personaCuidada is null || colaborador is null) return false;

            var existeAsignacion = this.EntityLoaderDomainService.Query<AsignacionCuidado>()
                .Any(a => a.PersonaCuidada.ID == personaCuidada.ID
                       && a.Colaborador.ID == colaborador.ID
                       && (a.Estado.ID == EstadosAsignacionCuidado.Activa || a.Estado.ID == EstadosAsignacionCuidado.Pendiente));

            return existeAsignacion;
        }
    }
}
