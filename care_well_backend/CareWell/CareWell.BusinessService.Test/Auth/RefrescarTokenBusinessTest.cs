using CareWell.BusinessService.Abstractions.Auth;
using CareWell.BusinessService.Auth;
using CareWell.DataViews.Auth;
using CareWell.Domain.Auth;
using CareWell.Queries.Auth;
using CareWell.Repository.Auth;
using Moq;

namespace CareWell.BusinessService.Test.Auth
{
    public class RefrescarTokenBusinessTest : BusinessTestClassBase<RefrescarTokenBusinessService>
    {
        private Mock<IRefreshTokenRepository> refreshTokenRepository;
        private Mock<ITokenAutorizacionBusinessService> tokenAutorizacionBusinessService;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.refreshTokenRepository = new Mock<IRefreshTokenRepository>();
            this.tokenAutorizacionBusinessService = new Mock<ITokenAutorizacionBusinessService>();

            this.Target = new RefrescarTokenBusinessService(this.refreshTokenRepository.Object,
                                                            this.tokenAutorizacionBusinessService.Object);
        }

        public class ElMetodo_Refrescar : RefrescarTokenBusinessTest
        {
            private RefrescarTokenQuery query;
            private Mock<RefreshToken> refreshToken;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<RefrescarTokenQuery>(q => q.RefreshToken == "1234");

                this.refreshToken = new Mock<RefreshToken>();
                this.refreshToken.Setup(s => s.Usuario).Returns(Mock.Of<Usuario>(u => u.ID == 1 && u.NombreUsuario == "correo@example.com"));
                this.refreshToken.Setup(s => s.HabilitadoUso()).Returns(true);

                this.refreshTokenRepository.Setup(s => s.GetByToken(this.query.RefreshToken)).Returns(this.refreshToken.Object);

                this.tokenAutorizacionBusinessService.Setup(s => s.GenerarTokenAcceso(It.IsAny<GenerarTokenAccesoQuery>())).Returns(new AccessTokenDataView());
            }

            private LoginDataView Action()
            {
                return this.Target.Refrescar(this.query);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByToken_del_RefreshTokenRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.refreshTokenRepository.Verify(v => v.GetByToken(this.query.RefreshToken), Times.Once);
            }

            [Fact]
            public void Si_el_RefreshToken_es_null_arroja_un_UnathorizedAccessException()
            {
                // Arrange
                this.refreshTokenRepository.Setup(s => s.GetByToken(It.IsAny<string>())).Returns((RefreshToken?)null);

                // Action & Assert
                Assert.Throws<UnauthorizedAccessException>(() => this.Action());
            }

            [Fact]
            public void Si_el_RefreshToken_no_esta_habilitado_para_el_uso_arroja_un_UnathorizedAccessException()
            {
                // Arrange
                this.refreshToken.Setup(s => s.HabilitadoUso()).Returns(false);

                // Action & Assert
                Assert.Throws<UnauthorizedAccessException>(() => this.Action());
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Revocar_del_RefreshToken()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.refreshToken.Verify(v => v.Revocar(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GenerarTokenAcceso_del_TokenAutorizacionBusinessService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.tokenAutorizacionBusinessService.Verify(v => v.GenerarTokenAcceso(It.Is<GenerarTokenAccesoQuery>(q =>
                                                                  q.UsuarioID == this.refreshToken.Object.Usuario.ID &&
                                                                  q.Email == this.refreshToken.Object.Usuario.NombreUsuario)), Times.Once);
            }

            [Fact]
            public void Setea_el_token_generado_en_la_respuesta()
            {
                // Arrange
                var accessToken = "TKN";
                this.tokenAutorizacionBusinessService.Setup(s => s.GenerarTokenAcceso(It.IsAny<GenerarTokenAccesoQuery>())).Returns(new AccessTokenDataView { AccessToken = accessToken });

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(accessToken, respuesta.AccessToken);
            }

            [Fact]
            public void Setea_la_expiracion_en_la_respuesta()
            {
                // Arrange
                var expiracion = DateTime.UtcNow.AddMinutes(30);

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.InRange(respuesta.Expiracion, expiracion.AddSeconds(-1), expiracion.AddSeconds(1));
            }

            [Fact]
            public void Setea_el_ID_de_usuario_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.refreshToken.Object.Usuario.ID, respuesta.UsuarioID);
            }

            [Fact]
            public void Setea_el_nombre_de_usuario_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.refreshToken.Object.Usuario.NombreUsuario, respuesta.Email);
            }

            [Fact]
            public void Setea_el_token_de_refresco_generado_en_la_respuesta()
            {
                // Arrange
                var refreshToken = "RTKN";
                this.tokenAutorizacionBusinessService.Setup(s => s.GenerarTokenAcceso(It.IsAny<GenerarTokenAccesoQuery>())).Returns(new AccessTokenDataView { RefreshToken = refreshToken });

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(refreshToken, respuesta.RefreshToken);
            }

            [Fact]
            public void Retorna_una_instancia_del_tipo_LoginDataView()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.IsType<LoginDataView>(respuesta);
            }
        }
    }
}
