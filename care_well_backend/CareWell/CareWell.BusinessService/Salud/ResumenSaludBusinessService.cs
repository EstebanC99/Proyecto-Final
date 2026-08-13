using CareWell.BusinessService.Abstractions.Salud;
using CareWell.DataViews.Salud;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Queries.Salud;
using CareWell.Repository;
using CareWell.Repository.Salud;
using CareWell.Security;

namespace CareWell.BusinessService.Salud
{
    public class ResumenSaludBusinessService : BusinessService, IResumenSaludBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }
        private IResumenSaludRepository ResumenSaludRepository { get; set; }

        public ResumenSaludBusinessService(IUnitOfWork unitOfWork,
                                           IUserContext userContext,
                                           IEntityLoaderDomainService entityLoaderDomainService,
                                           IValidadorPermisoAccion validadorPermisoAccion,
                                           IResumenSaludRepository resumenSaludRepository)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
            this.ResumenSaludRepository = resumenSaludRepository;
        }

        public ResumenSaludDataView Obtener(ResumenSaludQuery query)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var persona = this.EntityLoaderDomainService.GetByID<Persona>(query.PersonaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(persona, usuario.Persona);

            return this.ResumenSaludRepository.Obtener(query);
        }
    }
}
