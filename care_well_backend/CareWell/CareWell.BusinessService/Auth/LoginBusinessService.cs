using CareWell.BusinessService.Abstractions.Auth;
using CareWell.DataViews.Auth;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Queries.Auth;
using CareWell.Repository;
using CareWell.Repository.Auth;

namespace CareWell.BusinessService.Auth
{
    public class LoginBusinessService : BusinessService, ILoginBusinessService
    {
        private IUsuarioRepository UsuarioRepository { get; set; }
        private IPasswordHasherDomainService PasswordHasherDomainService { get; set; }
        private ITokenAutorizacionBusinessService TokenAutorizacionBusinessService { get; set; }

        public LoginBusinessService(IUnitOfWork unitOfWork,
                                    IUsuarioRepository usuarioRepository,
                                    IPasswordHasherDomainService passwordHasherDomainService,
                                    ITokenAutorizacionBusinessService tokenAutorizacionBusinessService)
            : base(unitOfWork)
        {
            this.UsuarioRepository = usuarioRepository;
            this.PasswordHasherDomainService = passwordHasherDomainService;
            this.TokenAutorizacionBusinessService = tokenAutorizacionBusinessService;
        }

        public LoginDataView Login(LoginQuery query)
        {
            var usuario = this.UsuarioRepository.GetByEmail(query.Email);

            if (usuario == null || !this.PasswordHasherDomainService.Verificar(query.Contrasena, usuario.ContrasenaHash))
                throw new UnauthorizedAccessException();

            var expiracion = DateTime.UtcNow.AddMinutes(30);
            var accessTokenDataView = this.TokenAutorizacionBusinessService.GenerarTokenAcceso(new GenerarTokenAccesoQuery
            {
                UsuarioID = usuario.ID,
                Email = usuario.NombreUsuario
            });

            return new LoginDataView
            {
                AccessToken = accessTokenDataView.AccessToken,
                Expiracion = expiracion,
                UsuarioID = usuario.ID,
                Email = usuario.NombreUsuario,
                RefreshToken = accessTokenDataView.RefreshToken
            };
        }
    }
}
