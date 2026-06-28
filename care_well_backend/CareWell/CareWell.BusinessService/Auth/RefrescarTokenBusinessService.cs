using CareWell.BusinessService.Abstractions.Auth;
using CareWell.DataViews.Auth;
using CareWell.DataViews.General;
using CareWell.Domain.Auth;
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
                Expiracion = DateTime.Now.AddMinutes(30),
                RefreshToken = accessTokenDataView.RefreshToken,
                Usuario = new UsuarioDataView
                {
                    ID = refreshToken.Usuario.ID,
                    NombreUsuario = refreshToken.Usuario.NombreUsuario,
                    Persona = new PersonaDataView
                    {
                        ID = refreshToken.Usuario.Persona.ID,
                        Nombre = refreshToken.Usuario.Persona.Nombre,
                        Apellido = refreshToken.Usuario.Persona.Apellido,
                        Documento = refreshToken.Usuario.Persona.Documento,
                        FechaNacimiento = refreshToken.Usuario.Persona.FechaNacimiento,
                        Email = refreshToken.Usuario.Persona.Email,
                        Telefono = refreshToken.Usuario.Persona.Telefono,
                        ImagenPath = refreshToken.Usuario.Persona.ImagenPath
                    },
                    Estado = new EstadoUsuarioDataView
                    {
                        ID = refreshToken.Usuario.Estado.ID,
                        Descripcion = refreshToken.Usuario.Estado.Descripcion
                    }
                }
            };
        }
    }
}
