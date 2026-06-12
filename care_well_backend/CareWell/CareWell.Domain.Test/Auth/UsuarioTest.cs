using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.General;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Auth
{
    public class UsuarioTest : TestClassBase<Usuario>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new Usuario();
        }

        public class ElMetodo_Crear : UsuarioTest
        {
            private Persona persona;
            private string email, contrasena;
            private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
            private Mock<IPasswordHasherDomainService> passwordHasherDomainService;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.persona = Mock.Of<Persona>();
                this.email = "email@example.com";
                this.contrasena = "12345678";

                this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
                this.passwordHasherDomainService = new Mock<IPasswordHasherDomainService>();

                this.entityLoaderDomainService.Setup(s => s.GetByID<EstadoUsuario>(EstadosUsuario.Activo)).Returns(Mock.Of<EstadoUsuario>(e => e.ID == EstadosUsuario.Activo));
            }

            private void Action()
            {
                this.Target.Crear(this.persona,
                                  this.email,
                                  this.contrasena,
                                  this.entityLoaderDomainService.Object,
                                  this.passwordHasherDomainService.Object);
            }

            [Fact]
            public void Si_Persona_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.persona = null;

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.PersonaNoExiste, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Email_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.email = null;

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.EmailRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Contrasena_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.contrasena = null;

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ContrasenaRequerida, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_existe_un_usuario_con_mismo_email_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                var usuarioExistente = Mock.Of<Usuario>(u => u.NombreUsuario == this.email);
                this.entityLoaderDomainService.Setup(s => s.Query<Usuario>()).Returns(new List<Usuario> { usuarioExistente }.AsQueryable);

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NombreUsuarioEnUso, excepcionEsperada.Message);
            }

            [Fact]
            public void Setea_la_propiedad_Persona()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.persona, this.Target.Persona);
            }

            [Fact]
            public void Setea_la_propiedad_NombreUsuario()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.email, this.Target.NombreUsuario);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Hashear_del_servicio_PasswordHasherDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.passwordHasherDomainService.Verify(v => v.Hashear(this.contrasena), Times.Once);
            }

            [Fact]
            public void Setea_la_propiedad_ContrasenaHash_con_lo_retornado_por_el_servicio_PasswordHasherDomainService()
            {
                // Arrange
                var contrasenaHash = "XXXXXX";
                this.passwordHasherDomainService.Setup(s => s.Hashear(this.contrasena)).Returns(contrasenaHash);

                // Action
                this.Action();

                // Assert
                Assert.Equal(contrasenaHash, this.Target.ContrasenaHash);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_EstadoUsuario_con_estado_Activo_del_servicio_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<EstadoUsuario>(EstadosUsuario.Activo), Times.Once);
            }

            [Fact]
            public void Setea_la_propiedad_Estado_con_el_estado_retornado_por_el_servicio_EntityLoaderDomainService()
            {
                // Arrange
                var estadoActivo = Mock.Of<EstadoUsuario>(e => e.ID == EstadosUsuario.Activo);
                this.entityLoaderDomainService.Setup(s => s.GetByID<EstadoUsuario>(EstadosUsuario.Activo)).Returns(estadoActivo);

                // Action
                this.Action();

                // Assert
                Assert.Same(estadoActivo, this.Target.Estado);
            }
        }
    }
}
