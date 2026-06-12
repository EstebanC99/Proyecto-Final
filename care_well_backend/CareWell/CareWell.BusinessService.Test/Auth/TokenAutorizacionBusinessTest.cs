using CareWell.BusinessService.Auth;
using CareWell.DataViews.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.Factories;
using CareWell.Queries.Auth;
using CareWell.Repository.Auth;
using Microsoft.Extensions.Configuration;
using Moq;

namespace CareWell.BusinessService.Test.Auth
{
    public class TokenAutorizacionBusinessTest : BusinessTestClassBase<TokenAutorizacionBusinessService>
    {
        private Mock<IConfiguration> configuration;
        private Mock<IBaseFactory> baseFactory;
        private Mock<IRefreshTokenRepository> refreshTokenRepository;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.configuration = new Mock<IConfiguration>();
            this.baseFactory = new Mock<IBaseFactory>();
            this.refreshTokenRepository = new Mock<IRefreshTokenRepository>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();

            this.configuration.Setup(s => s["Jwt:Key"]).Returns("hdIkC*g=l&1XnSJ<ZdD21wZhW);d6_2h");
            this.configuration.Setup(s => s["Jwt:Issuer"]).Returns("CareWellAPI");
            this.configuration.Setup(s => s["Jwt:Audience"]).Returns("CareWellAPI");

            this.Target = new TokenAutorizacionBusinessService(this.unitOfWork.Object,
                                                               this.configuration.Object,
                                                               this.baseFactory.Object,
                                                               this.refreshTokenRepository.Object,
                                                               this.entityLoaderDomainService.Object);
        }

        public class ElMetodo_GenerarTokenAcceso : TokenAutorizacionBusinessTest
        {
            private GenerarTokenAccesoQuery query;
            private Mock<RefreshToken> refreshToken;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<GenerarTokenAccesoQuery>(q =>
                    q.UsuarioID == 1 &&
                    q.Email == "correo@example.com");

                this.refreshToken = new Mock<RefreshToken>();
                this.refreshToken.Setup(s => s.Token).Returns("RTKN");

                this.baseFactory.Setup(s => s.Crear<RefreshToken>()).Returns(this.refreshToken.Object);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(this.query.UsuarioID)).Returns(Mock.Of<Usuario>());
            }

            private AccessTokenDataView Action()
            {
                return this.Target.GenerarTokenAcceso(this.query);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_RefreshToken_de_la_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<RefreshToken>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Usuario>(this.query.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_del_RefreshToken()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.refreshToken.Verify(v => v.Crear(It.IsAny<string>(), It.IsAny<Usuario>(), It.IsAny<DateTime>()), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_RefreshTokenRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.refreshTokenRepository.Verify(v => v.Add(this.refreshToken.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(v => v.SaveChanges(), Times.Once);
            }

            [Fact]
            public void Setea_el_token_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.False(string.IsNullOrEmpty(respuesta.AccessToken));
            }

            [Fact]
            public void Setea_el_token_de_refresco_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.refreshToken.Object.Token, respuesta.RefreshToken);
            }

            [Fact]
            public void Retorna_una_instancia_del_tipo_AccessTokenDataView()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.IsType<AccessTokenDataView>(respuesta);
            }
        }
    }
}
