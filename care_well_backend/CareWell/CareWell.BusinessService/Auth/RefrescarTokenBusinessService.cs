using CareWell.BusinessService.Abstractions.Auth;
using CareWell.DataViews.Auth;
using CareWell.Queries.Auth;
using CareWell.Repository.Auth;

namespace CareWell.BusinessService.Auth
{
    public class RefrescarTokenBusinessService : IRefrescarTokenBusinessService
    {
        private IRefreshTokenRepository RefreshTokenRepository { get; set; }
        private ITokenAutorizacionBusinessService TokenAutorizacionBusinessService { get; set; }

        public RefrescarTokenBusinessService(IRefreshTokenRepository refreshTokenRepository,
                                             ITokenAutorizacionBusinessService tokenAutorizacionBusinessService)
        {
            this.RefreshTokenRepository = refreshTokenRepository;
            this.TokenAutorizacionBusinessService = tokenAutorizacionBusinessService;
        }

        public LoginDataView Refrescar(RefrescarTokenQuery query)
        {
            var refreshToken = this.RefreshTokenRepository.GetByToken(query.RefreshToken);

            if (refreshToken == null || !refreshToken.HabilitadoUso())
                throw new UnauthorizedAccessException();

            refreshToken.Revocar();

            var accessTokenDataView = this.TokenAutorizacionBusinessService.GenerarTokenAcceso(new GenerarTokenAccesoQuery
            {
                UsuarioID = refreshToken.Usuario.ID,
                Email = refreshToken.Usuario.NombreUsuario
            });

            return new LoginDataView
            {
                AccessToken = accessTokenDataView.AccessToken,
                RefreshToken = accessTokenDataView.RefreshToken,
                Expiracion = DateTime.UtcNow.AddMinutes(30),
                UsuarioID = refreshToken.Usuario.ID,
                Email = refreshToken.Usuario.NombreUsuario
            };
        }
    }
}
