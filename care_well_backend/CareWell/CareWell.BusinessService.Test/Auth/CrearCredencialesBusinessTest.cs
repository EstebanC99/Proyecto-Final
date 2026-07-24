using CareWell.BusinessService.Abstractions.Auth;
using CareWell.BusinessService.Auth;
using CareWell.Commands.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.DomainServices.General;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using CareWell.Repository.Auth;
using CareWell.Repository.General;
using Microsoft.Extensions.Logging;
using Moq;

namespace CareWell.BusinessService.Test.Auth
{
    public class CrearCredencialesBusinessTest : BusinessTestClassBase<CrearCredencialesBusinessService>
    {
        private Mock<IPersonaRepository> personaRepository;
        private Mock<IUsuarioRepository> usuarioRepository;
        private Mock<IBaseFactory> baseFactory;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IPasswordHasherDomainService> passwordHasherDomainService;
        private Mock<IVerificacionEmailBusinessService> verificacionEmailBusinessService;
        private Mock<IEvaluadorIdentidadPersonaDomainService> evaluadorIdentidadPersonaDomainService;
        private Mock<ILogger<CrearCredencialesBusinessService>> logger;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.personaRepository = new Mock<IPersonaRepository>();
            this.usuarioRepository = new Mock<IUsuarioRepository>();
            this.baseFactory = new Mock<IBaseFactory>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.passwordHasherDomainService = new Mock<IPasswordHasherDomainService>();
            this.verificacionEmailBusinessService = new Mock<IVerificacionEmailBusinessService>();
            this.evaluadorIdentidadPersonaDomainService = new Mock<IEvaluadorIdentidadPersonaDomainService>();
            this.logger = new Mock<ILogger<CrearCredencialesBusinessService>>();

            this.Target = new CrearCredencialesBusinessService(
                this.unitOfWork.Object,
                this.personaRepository.Object,
                this.usuarioRepository.Object,
                this.baseFactory.Object,
                this.entityLoaderDomainService.Object,
                this.passwordHasherDomainService.Object,
                this.verificacionEmailBusinessService.Object,
                this.evaluadorIdentidadPersonaDomainService.Object,
                this.logger.Object
            );
        }

        public class ElMetodo_Crear : CrearCredencialesBusinessTest
        {
            private CrearCredencialesCommand command;
            private Mock<Persona> persona;
            private Mock<Usuario> usuario;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<CrearCredencialesCommand>(c => c.Email == "mail@algo.com");

                this.persona = new Mock<Persona>();
                this.usuario = new Mock<Usuario>();

                this.personaRepository.Setup(s => s.GetByEmail(this.command.Email)).Returns(this.persona.Object);

                this.baseFactory.Setup(s => s.Crear<Usuario>()).Returns(this.usuario.Object);

                this.evaluadorIdentidadPersonaDomainService.Setup(s => s.EsIdentidadCorrecta(this.persona.Object, It.IsAny<byte[]>())).Returns(true);
            }

            private void Action()
            {
                this.Target.Crear(this.command);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByEmail_de_PersonaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaRepository.Verify(v => v.GetByEmail(this.command.Email), Times.Once);
            }

            [Fact]
            public void Si_la_Persona_no_se_encuentra_arroja_un_RecursoNoEncontradoException_con_mensaje_informativo()
            {
                // Arrange
                this.personaRepository.Setup(s => s.GetByEmail(this.command.Email)).Returns((Persona?)null);

                // Action & Assert
                var excepcion = Assert.Throws<RecursoNoEncontradoException>(() => this.Action());
                Assert.Equal(Mensajes.NoExistePersonaConEseEmail, excepcion.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarCrearUsuario_de_la_Persona()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.persona.Verify(v => v.ValidarCrearUsuario(this.entityLoaderDomainService.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_EsIdentidadCorrecta_del_EvaluadorIdentidadPersonaDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.evaluadorIdentidadPersonaDomainService.Verify(v => v.EsIdentidadCorrecta(this.persona.Object, It.IsAny<byte[]?>()), Times.Once);
            }

            [Fact]
            public void Si_el_metodo_EsIdentidadCorrecta_del_EvaluadorIdentidadPersonaDomainService_retorna_false_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.evaluadorIdentidadPersonaDomainService.Setup(s => s.EsIdentidadCorrecta(this.persona.Object, It.IsAny<byte[]>())).Returns(false);

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.IdentidadNoValidada, excepcion.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_Usuario_de_la_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<Usuario>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_del_Usuario()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.usuario.Verify(v => v.Crear(this.persona.Object,
                                                 this.command.Email,
                                                 this.command.Contrasena,
                                                 this.entityLoaderDomainService.Object,
                                                 this.passwordHasherDomainService.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_UsuarioRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.usuarioRepository.Verify(v => v.Add(this.usuario.Object), Times.Once);
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
            public void Llama_una_vez_al_metodo_EnviarCodigo_del_VerificacionEmailBusinessService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.verificacionEmailBusinessService.Verify(v => v.EnviarCodigo(It.Is<EnviarCodigoVerificacionCommand>(c => c.Email == this.command.Email)), Times.Once);
            }

            [Fact]
            public void Si_se_produce_un_error_al_enviar_el_codigo_no_lo_arroja()
            {
                // Arrange
                this.verificacionEmailBusinessService.Setup(v => v.EnviarCodigo(It.IsAny<EnviarCodigoVerificacionCommand>())).Throws(new Exception());

                // Action
                var exception = Record.Exception(() => this.Action());

                // Assert
                Assert.Null(exception);
            }
        }
    }
}
