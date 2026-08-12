using CareWell.BusinessService.Abstractions.General;
using CareWell.DataViews.General;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Queries.General;
using CareWell.Repository;
using CareWell.Security;

namespace CareWell.BusinessService.General
{
    public class ResumenDiarioBusinessService : BusinessService, IResumenDiarioBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }
        private IArmarResumenDiarioBusinessService ArmarResumenDiarioBusinessService { get; set; }

        public ResumenDiarioBusinessService(IUnitOfWork unitOfWork,
                                            IUserContext userContext,
                                            IEntityLoaderDomainService entityLoaderDomainService,
                                            IValidadorPermisoAccion validadorPermisoAccion,
                                            IArmarResumenDiarioBusinessService armarResumenDiarioBusinessService)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
            this.ArmarResumenDiarioBusinessService = armarResumenDiarioBusinessService;
        }

        public async Task<ResumenDiarioDataView> Generar(GenerarResumenDiarioQuery query, CancellationToken cancellationToken)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var personaCuidada = this.EntityLoaderDomainService.GetByID<Persona>(query.PersonaCuidadaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(personaCuidada, usuario.Persona);

            return await this.ArmarResumenDiarioBusinessService.Armar(personaCuidada.ID, personaCuidada.Nombre, cancellationToken);
        }
    }
}
