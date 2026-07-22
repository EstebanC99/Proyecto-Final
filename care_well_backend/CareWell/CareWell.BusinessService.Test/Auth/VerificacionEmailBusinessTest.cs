using CareWell.BusinessService.Abstractions.Auth;
using CareWell.BusinessService.Auth;
using CareWell.Commands.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Auth;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using CareWell.Global.Notificaciones;
using CareWell.Repository.Auth;
using Moq;

namespace CareWell.BusinessService.Test.Auth
{
    public class VerificacionEmailBusinessTest : BusinessTestClassBase<VerificacionEmailBusinessService>
    {
        private Mock<IUsuarioRepository> usuarioRepository;
        private Mock<ICodigoVerificacionEmailRepository> codigoVerificacionEmailRepository;
        private Mock<IBaseFactory> baseFactory;
        private Mock<IPasswordHasherDomainService> passwordHasherDomainService;
        private Mock<IGeneradorCodigoOtpDomainService> generadorCodigoOtpDomainService;
        private Mock<IEnvioEmailBusinessService> envioEmailBusinessService;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IValidadorLimiteEnvioEmail> validadorLimiteEnvioEmail;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.usuarioRepository = new Mock<IUsuarioRepository>();
            this.codigoVerificacionEmailRepository = new Mock<ICodigoVerificacionEmailRepository>();
            this.baseFactory = new Mock<IBaseFactory>();
            this.passwordHasherDomainService = new Mock<IPasswordHasherDomainService>();
            this.generadorCodigoOtpDomainService = new Mock<IGeneradorCodigoOtpDomainService>();
            this.envioEmailBusinessService = new Mock<IEnvioEmailBusinessService>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.validadorLimiteEnvioEmail = new Mock<IValidadorLimiteEnvioEmail>();

            this.Target = new VerificacionEmailBusinessService(
                this.unitOfWork.Object,
                this.usuarioRepository.Object,
                this.codigoVerificacionEmailRepository.Object,
                this.baseFactory.Object,
                this.passwordHasherDomainService.Object,
                this.generadorCodigoOtpDomainService.Object,
                this.envioEmailBusinessService.Object,
                this.entityLoaderDomainService.Object,
                this.validadorLimiteEnvioEmail.Object
            );
        }

        public class ElMetodo_EnviarCodigo : VerificacionEmailBusinessTest
        {
            private EnviarCodigoVerificacionEmailCommand command;
            private Mock<Usuario> usuario;
            private Mock<CodigoVerificacionEmail> codigoVerificacionEmail;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<EnviarCodigoVerificacionEmailCommand>(c => c.Email == "mail@algo.com");

                this.usuario = new Mock<Usuario>();
                this.usuario.Setup(s => s.ID).Returns(1);
                this.usuario.Setup(s => s.NombreUsuario).Returns("mail@algo.com");
                this.usuario.Setup(s => s.Persona).Returns(Mock.Of<Persona>(p => p.Nombre == "Persona X"));

                this.codigoVerificacionEmail = new Mock<CodigoVerificacionEmail>();

                this.usuarioRepository.Setup(s => s.GetByEmail(It.IsAny<string>())).Returns(this.usuario.Object);

                this.baseFactory.Setup(s => s.Crear<CodigoVerificacionEmail>()).Returns(this.codigoVerificacionEmail.Object);
            }

            private void Action()
            {
                this.Target.EnviarCodigo(this.command);
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
            public void Si_no_se_encuentra_el_usuario_no_genera_un_codigo_de_verificacion()
            {
                // Arrange
                this.usuarioRepository.Setup(s => s.GetByEmail(It.IsAny<string>())).Returns((Usuario?)null);

                // Action
                this.Action();

                // Assert
                this.generadorCodigoOtpDomainService.Verify(v => v.Generar(), Times.Never);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarCantidadEnviosUltimaHora_del_ValidadorLimiteEnvioEmail()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorLimiteEnvioEmail.Verify(v => v.ValidarCantidadEnviosUltimaHora(this.usuario.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetVigentePorUsuario_del_CodigoVerificacionEmailRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.codigoVerificacionEmailRepository.Verify(v => v.GetVigentePorUsuario(this.usuario.Object.ID), Times.Once);
            }

            [Fact]
            public void Si_existia_un_codigo_vigente_para_el_usuario_llama_al_Consumir_del_mismo()
            {
                // Arrange
                this.codigoVerificacionEmailRepository.Setup(s => s.GetVigentePorUsuario(this.usuario.Object.ID)).Returns(this.codigoVerificacionEmail.Object);

                // Action
                this.Action();

                // Assert
                this.codigoVerificacionEmail.Verify(v => v.Consumir(), Times.Once);
            }

            [Fact]
            public void Si_se_encuentra_el_usuario_llama_una_vez_al_metodo_Generar_del_CodigoVerificacionEmailRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.generadorCodigoOtpDomainService.Verify(v => v.Generar(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Hashear_del_PasswordHasherDomainService()
            {
                // Arrange
                var codigoGenerado = "Codigo X";
                this.generadorCodigoOtpDomainService.Setup(s => s.Generar()).Returns(codigoGenerado);

                // Action
                this.Action();

                // Assert
                this.passwordHasherDomainService.Verify(v => v.Hashear(codigoGenerado), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_CodigoVerificacionEmail_de_la_Factory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<CodigoVerificacionEmail>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_del_CodigoVerificacionEmail()
            {
                // Arrange
                var codigoHash = "Codigo Hasheado";
                this.passwordHasherDomainService.Setup(s => s.Hashear(It.IsAny<string>())).Returns(codigoHash);

                // Action
                this.Action();

                // Assert
                this.codigoVerificacionEmail.Verify(v => v.Crear(It.Is<CrearCodigoVerificacionEmail>(c =>
                    c.Usuario == this.usuario.Object &&
                    c.CodigoHash == codigoHash
                )), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_CodigoVerificacionEmailRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.codigoVerificacionEmailRepository.Verify(v => v.Add(this.codigoVerificacionEmail.Object), Times.Once);
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
            public void Llama_una_vez_al_metodo_Enviar_del_EnvioEmailBusinessService()
            {
                // Arrange
                var codigoGenerado = "Codigo X";
                this.generadorCodigoOtpDomainService.Setup(s => s.Generar()).Returns(codigoGenerado);

                // Action
                this.Action();

                // Assert
                this.envioEmailBusinessService.Verify(v => v.Enviar(It.Is<EnviarEmailCommand>(c =>
                    c.Destinatario == this.usuario.Object.NombreUsuario &&
                    c.NombreDestinatario == this.usuario.Object.Persona.Nombre &&
                    c.Asunto == Emails.AsuntoCodigoVerificacionCareWell &&
                    c.CuerpoHtml == Emails.CodigoVerificacionEmailFormat(codigoGenerado, ParametrosVerificacionEmail.MinutosExpiracion.ToString())
                )), Times.Once);
            }
        }

        public class ElMetodo_Verificar : VerificacionEmailBusinessTest
        {
            private VerificarEmailCommand command;
            private Mock<Usuario> usuario;
            private Mock<CodigoVerificacionEmail> codigoVerificacionEmail;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<VerificarEmailCommand>(c => c.Email == "mail@algo.com");

                this.usuario = new Mock<Usuario>();
                this.usuario.Setup(s => s.ID).Returns(1);

                this.codigoVerificacionEmail = new Mock<CodigoVerificacionEmail>();

                this.usuarioRepository.Setup(s => s.GetByEmail(It.IsAny<string>())).Returns(this.usuario.Object);

                this.codigoVerificacionEmailRepository.Setup(s => s.GetVigentePorUsuario(It.IsAny<int>())).Returns(this.codigoVerificacionEmail.Object);
            }

            private void Action()
            {
                this.Target.Verificar(this.command);
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
                Assert.Equal(Mensajes.CodigoVerificacionEmailInvalido, excepcion.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetVigentePorUsuario_del_CodigoVerificacionEmailRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.codigoVerificacionEmailRepository.Verify(v => v.GetVigentePorUsuario(this.usuario.Object.ID), Times.Once);
            }

            [Fact]
            public void Si_no_se_encuentra_el_codigo_vigente_arroja_un_ValidacionDominioException_con_mensaje_de_codigo_incorrecto()
            {
                // Arrange
                this.codigoVerificacionEmailRepository.Setup(v => v.GetVigentePorUsuario(this.usuario.Object.ID)).Returns((CodigoVerificacionEmail?)null);

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.CodigoVerificacionEmailInvalido, excepcion.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Verificar_del_CodigoVerificacionEmail()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.codigoVerificacionEmail.Verify(v => v.Verificar(command.Codigo, this.passwordHasherDomainService.Object), Times.Once);
            }

            [Fact]
            public void Si_se_produce_un_error_al_verificar_el_codigo_llama_al_SaveChanges_del_UnitOfWork_de_todas_formas()
            {
                // Arrange
                this.codigoVerificacionEmail.Setup(v => v.Verificar(command.Codigo, this.passwordHasherDomainService.Object)).Throws(new Exception());

                // Action & Assert
                Assert.Throws<Exception>(() => this.Action());
                this.unitOfWork.Verify(v => v.SaveChanges(), Times.Once);
            }

            [Fact]
            public void Si_se_produce_un_error_al_verificar_el_codigo_no_llama_al_ConfirmarEmail_del_Usuario()
            {
                // Arrange
                this.codigoVerificacionEmail.Setup(v => v.Verificar(command.Codigo, this.passwordHasherDomainService.Object)).Throws(new Exception());

                // Action & Assert
                Assert.Throws<Exception>(() => this.Action());
                this.usuario.Verify(v => v.ConfirmarEmail(this.entityLoaderDomainService.Object), Times.Never);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ConfirmarEmail_del_Usuario()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.usuario.Verify(v => v.ConfirmarEmail(this.entityLoaderDomainService.Object), Times.Once);
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
