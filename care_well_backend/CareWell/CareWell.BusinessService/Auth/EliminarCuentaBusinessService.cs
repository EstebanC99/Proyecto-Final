using CareWell.BusinessService.Abstractions.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Repository;
using CareWell.Repository.Auth;
using CareWell.Security;

namespace CareWell.BusinessService.Auth
{
    public class EliminarCuentaBusinessService : BusinessService, IEliminarCuentaBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IUsuarioRepository UsuarioRepository { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IAdministrarDispositivoDomainService AdministrarDispositivoDomainService { get; set; }

        public EliminarCuentaBusinessService(IUnitOfWork unitOfWork,
                                             IUserContext userContext,
                                             IUsuarioRepository usuarioRepository,
                                             IEntityLoaderDomainService entityLoaderDomainService,
                                             IAdministrarDispositivoDomainService administrarDispositivoDomainService)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.UsuarioRepository = usuarioRepository;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.AdministrarDispositivoDomainService = administrarDispositivoDomainService;
        }

        public void Eliminar()
        {
            var usuario = this.UsuarioRepository.GetByID(this.UserContext.UsuarioID);

            usuario.Eliminar(this.EntityLoaderDomainService);

            this.AdministrarDispositivoDomainService.DesactivarTodosDelUsuario(usuario);

            this.UnitOfWork.SaveChanges();
        }
    }
}
