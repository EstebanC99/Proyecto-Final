using CareWell.BusinessService.Abstractions.Auth;
using CareWell.Domain.DomainServices;
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

        public EliminarCuentaBusinessService(IUnitOfWork unitOfWork,
                                             IUserContext userContext,
                                             IUsuarioRepository usuarioRepository,
                                             IEntityLoaderDomainService entityLoaderDomainService)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.UsuarioRepository = usuarioRepository;
            this.EntityLoaderDomainService = entityLoaderDomainService;
        }

        public void Eliminar()
        {
            var usuario = this.UsuarioRepository.GetByID(this.UserContext.UsuarioID);

            usuario.Eliminar(this.EntityLoaderDomainService);

            this.UnitOfWork.SaveChanges();
        }
    }
}
