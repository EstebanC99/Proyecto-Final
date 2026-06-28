using CareWell.BusinessService.Abstractions.Auth;
using CareWell.BusinessService.Auth;
using CareWell.DataViews.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.General;
using CareWell.Queries.Auth;
using CareWell.Repository.Auth;
using Moq;

namespace CareWell.BusinessService.Test.Auth
{
    public class LoginBusinessTest : BusinessTestClassBase<LoginBusinessService>
    {
        private Mock<IUsuarioRepository> usuarioRepository;
        private Mock<IPasswordHasherDomainService> passwordHasherDomainService;
        private Mock<ITokenAutorizacionBusinessService> tokenAutorizacionBusinessService;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.usuarioRepository = new Mock<IUsuarioRepository>();
            this.passwordHasherDomainService = new Mock<IPasswordHasherDomainService>();
            this.tokenAutorizacionBusinessService = new Mock<ITokenAutorizacionBusinessService>();

            this.Target = new LoginBusinessService(this.unitOfWork.Object,
                                                   this.usuarioRepository.Object,
                                                   this.passwordHasherDomainService.Object,
                                                   this.tokenAutorizacionBusinessService.Object);
        }

        public class ElMetodo_Login : LoginBusinessTest
        {
            private LoginQuery query;
            private Mock<Usuario> usuario;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<LoginQuery>(q =>
                    q.Email == "correo@example.com" &&
                    q.Contrasena == "12345678");

                this.usuario = new Mock<Usuario>();
                this.usuario.Setup(s => s.ID).Returns(1);
                this.usuario.Setup(s => s.NombreUsuario).Returns("USER1");
                this.usuario.Setup(s => s.ContrasenaHash).Returns("HASH123");
                this.usuario.Setup(s => s.Persona).Returns(Mock.Of<Persona>(p =>
                    p.ID == 2 &&
                    p.Nombre == "Persona" &&
                    p.Apellido == "Random" &&
                    p.Documento == "41565323" &&
                    p.FechaNacimiento == DateTime.Now &&
                    p.Email == "persona@mail.com" &&
                    p.Telefono == "35123175"
                ));
                this.usuario.Setup(s => s.Estado).Returns(Mock.Of<EstadoUsuario>(e =>
                    e.ID == 1 &&
                    e.Descripcion == "Estado"
                ));

                this.usuarioRepository.Setup(s => s.GetByEmail(this.query.Email)).Returns(this.usuario.Object);

                this.passwordHasherDomainService.Setup(s => s.Verificar(this.query.Contrasena, this.usuario.Object.ContrasenaHash)).Returns(true);

                this.tokenAutorizacionBusinessService.Setup(s => s.GenerarTokenAcceso(It.IsAny<GenerarTokenAccesoQuery>())).Returns(new AccessTokenDataView());
            }

            private LoginDataView Action()
            {
                return this.Target.Login(this.query);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByEmail_del_UsuarioRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.usuarioRepository.Verify(v => v.GetByEmail(this.query.Email), Times.Once);
            }

            [Fact]
            public void Si_el_usuario_es_nulo_arroja_un_UnauthorizedAccessException()
            {
                // Arrange
                this.usuarioRepository.Setup(s => s.GetByEmail(It.IsAny<string>())).Returns((Usuario?)null);

                // Action & Assert
                Assert.Throws<UnauthorizedAccessException>(() => this.Action());
            }

            [Fact]
            public void Si_el_password_no_es_correcto_arroja_un_UnauthorizedAccessException()
            {
                // Arrange
                this.passwordHasherDomainService.Setup(s => s.Verificar(It.IsAny<string>(), It.IsAny<string>())).Returns(false);

                // Action & Assert
                Assert.Throws<UnauthorizedAccessException>(() => this.Action());
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GenerarTokenAcceso_del_TokenAutorizacionBusinessService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.tokenAutorizacionBusinessService.Verify(v => v.GenerarTokenAcceso(It.Is<GenerarTokenAccesoQuery>(t =>
                                                                                        t.UsuarioID == this.usuario.Object.ID &&
                                                                                        t.Email == this.usuario.Object.NombreUsuario)), Times.Once);
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
                var expiracion = DateTime.Now.AddMinutes(30);

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.InRange(respuesta.Expiracion, expiracion.AddSeconds(-1), expiracion.AddSeconds(1));
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
            public void Setea_el_ID_de_usuario_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.usuario.Object.ID, respuesta.Usuario.ID);
            }

            [Fact]
            public void Setea_el_nombre_de_usuario_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.usuario.Object.NombreUsuario, respuesta.Usuario.NombreUsuario);
            }

            [Fact]
            public void Setea_el_ID_de_la_persona_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.usuario.Object.Persona.ID, respuesta.Usuario.Persona.ID);
            }

            [Fact]
            public void Setea_el_nombre_de_la_persona_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.usuario.Object.Persona.Nombre, respuesta.Usuario.Persona.Nombre);
            }

            [Fact]
            public void Setea_el_apellido_de_la_persona_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.usuario.Object.Persona.Apellido, respuesta.Usuario.Persona.Apellido);
            }

            [Fact]
            public void Setea_el_documento_de_la_persona_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.usuario.Object.Persona.Documento, respuesta.Usuario.Persona.Documento);
            }

            [Fact]
            public void Setea_la_fecha_de_nacimiento_de_la_persona_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.usuario.Object.Persona.FechaNacimiento, respuesta.Usuario.Persona.FechaNacimiento);
            }

            [Fact]
            public void Setea_el_email_de_la_persona_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.usuario.Object.Persona.Email, respuesta.Usuario.Persona.Email);
            }

            [Fact]
            public void Setea_el_telefono_de_la_persona_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.usuario.Object.Persona.Telefono, respuesta.Usuario.Persona.Telefono);
            }

            [Fact]
            public void Setea_la_imagen_de_la_persona_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.usuario.Object.Persona.ImagenPath, respuesta.Usuario.Persona.ImagenPath);
            }

            [Fact]
            public void Setea_el_ID_del_estado_de_usuario_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.usuario.Object.Estado.ID, respuesta.Usuario.Estado.ID);
            }

            [Fact]
            public void Setea_la_descripcion_del_estado_usuario_en_la_respuesta()
            {
                // Arrange

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.Equal(this.usuario.Object.Estado.Descripcion, respuesta.Usuario.Estado.Descripcion);
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
