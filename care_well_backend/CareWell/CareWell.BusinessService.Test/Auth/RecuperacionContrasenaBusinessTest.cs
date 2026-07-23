using CareWell.BusinessService.Abstractions.Auth;
using CareWell.BusinessService.Auth;
using CareWell.Commands.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.General;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Enumeraciones.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using CareWell.Global.Notificaciones;
using CareWell.Repository.Auth;
using Moq;

namespace CareWell.BusinessService.Test.Auth
{
    public class RecuperacionContrasenaBusinessTest : BusinessTestClassBase<RecuperacionContrasenaBusinessService>
    {
        private Mock<IUsuarioRepository> usuarioRepository;
        private Mock<IGestorCodigoVerificacionDomainService> gestorCodigoVerificacionDomainService;
        private Mock<IEnvioEmailBusinessService> envioEmailBusinessService;
        private Mock<IRefreshTokenRepository> refreshTokenRepository;
        private Mock<IPasswordHasherDomainService> passwordHasherDomainService;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.usuarioRepository = new Mock<IUsuarioRepository>();
            this.gestorCodigoVerificacionDomainService = new Mock<IGestorCodigoVerificacionDomainService>();
            this.envioEmailBusinessService = new Mock<IEnvioEmailBusinessService>();
            this.refreshTokenRepository = new Mock<IRefreshTokenRepository>();
            this.passwordHasherDomainService = new Mock<IPasswordHasherDomainService>();

            this.Target = new RecuperacionContrasenaBusinessService(
                this.unitOfWork.Object,
                this.usuarioRepository.Object,
                this.gestorCodigoVerificacionDomainService.Object,
                this.envioEmailBusinessService.Object,
                this.refreshTokenRepository.Object,
                this.passwordHasherDomainService.Object
            );
        }

        public class ElMetodo_SolicitarReset : RecuperacionContrasenaBusinessTest
        {
            private SolicitarResetContrasenaCommand command;
            private Mock<Usuario> usuario;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<SolicitarResetContrasenaCommand>(c => c.Email == "mail@algo.com");

                this.usuario = new Mock<Usuario>();
                this.usuario.Setup(s => s.NombreUsuario).Returns("mail@algo.com");
                this.usuario.Setup(s => s.Persona).Returns(Mock.Of<Persona>(p => p.Nombre == "Persona X"));

                this.usuarioRepository.Setup(s => s.GetByEmail(this.command.Email)).Returns(this.usuario.Object);
            }

            private void Action()
            {
                this.Target.SolicitarReset(this.command);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByEmail_del_UsuarioRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.usuarioRepository.Verify(v => v.GetByEmail(this.command.Email), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarHabilitadoParaRecuperarContrasena_del_Usuario()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.usuario.Verify(v => v.ValidarHabilitadoParaRecuperarContrasena(), Times.Once);
            }

            [Fact]
            public void Si_no_se_encuentra_el_usuario_no_emite_un_codigo_de_verificacion()
            {
                // Arrange
                this.usuarioRepository.Setup(s => s.GetByEmail(It.IsAny<string>())).Returns((Usuario?)null);

                // Action
                this.Action();

                // Assert
                this.gestorCodigoVerificacionDomainService.Verify(v => v.EmitirCodigo(It.IsAny<Usuario>(), It.IsAny<TipoCodigoVerificacionEnum>()), Times.Never);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_EmitirCodigo_del_GestorCodigoVerificacionDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.gestorCodigoVerificacionDomainService.Verify(v => v.EmitirCodigo(this.usuario.Object, TipoCodigoVerificacionEnum.RecuperacionContrasena), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Enviar_del_EnvioEmailBusinessService()
            {
                // Arrange
                var codigoGenerado = "Codigo X";
                this.gestorCodigoVerificacionDomainService.Setup(s => s.EmitirCodigo(this.usuario.Object, TipoCodigoVerificacionEnum.RecuperacionContrasena)).Returns(codigoGenerado);

                // Action
                this.Action();

                // Assert
                this.envioEmailBusinessService.Verify(v => v.Enviar(It.Is<EnviarEmailCommand>(c =>
                    c.Destinatario == this.usuario.Object.NombreUsuario &&
                    c.NombreDestinatario == this.usuario.Object.Persona.Nombre &&
                    c.Asunto == Emails.AsuntoRestablecerContrasenaCareWell &&
                    c.CuerpoHtml == Emails.RecuperacionContrasenaFormat(codigoGenerado, ParametrosVerificacionCodigo.MinutosExpiracion.ToString())
                )), Times.Once);
            }
        }

        public class ElMetodo_ConfirmarReset : RecuperacionContrasenaBusinessTest
        {
            private ConfirmarResetContrasenaCommand command;
            private Mock<Usuario> usuario;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<ConfirmarResetContrasenaCommand>(c => c.Email == "mail@algo.com");

                this.usuario = new Mock<Usuario>();

                this.usuarioRepository.Setup(s => s.GetByEmail(this.command.Email)).Returns(this.usuario.Object);

                this.refreshTokenRepository.Setup(s => s.GetVigentesPorUsuario(this.usuario.Object)).Returns(new List<RefreshToken>());
            }

            private void Action()
            {
                this.Target.ConfirmarReset(this.command);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByEmail_del_UsuarioRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.usuarioRepository.Verify(v => v.GetByEmail(this.command.Email), Times.Once);
            }

            [Fact]
            public void Si_no_se_encuentra_el_usuario_arroja_un_ValidacionDominioException_con_mensaje_de_codigo_incorrecto()
            {
                // Arrange
                this.usuarioRepository.Setup(s => s.GetByEmail(It.IsAny<string>())).Returns((Usuario?)null);

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.CodigoVerificacionInvalido, excepcion.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarYConsumir_del_GestorCodigoVerificacionDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.gestorCodigoVerificacionDomainService.Verify(v => v.ValidarYConsumir(this.usuario.Object, TipoCodigoVerificacionEnum.RecuperacionContrasena, this.command.Codigo), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_RestablecerContrasena_del_Usuario()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.usuario.Verify(v => v.RestablecerContrasena(this.command.ContrasenaNueva, this.passwordHasherDomainService.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetVigentesPorUsuario_del_RefreshTokenRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.refreshTokenRepository.Verify(v => v.GetVigentesPorUsuario(this.usuario.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Revocar_de_cada_token_vigente_por_usuario()
            {
                // Arrange
                var refreshToken = new Mock<RefreshToken>();
                this.refreshTokenRepository.Setup(s => s.GetVigentesPorUsuario(this.usuario.Object)).Returns(new List<RefreshToken> { refreshToken.Object });

                // Action
                this.Action();

                // Assert
                refreshToken.Verify(v => v.Revocar(), Times.Once);
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
        }
    }
}
