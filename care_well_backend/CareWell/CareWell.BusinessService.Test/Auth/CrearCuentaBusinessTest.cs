using CareWell.BusinessService.Abstractions.Auth;
using CareWell.BusinessService.Auth;
using CareWell.Commands.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.ValueObjects.General;
using CareWell.Repository.Auth;
using CareWell.Repository.General;
using Microsoft.Extensions.Logging;
using Moq;

namespace CareWell.BusinessService.Test.Auth
{
    public class CrearCuentaBusinessTest : BusinessTestClassBase<CrearCuentaBusinessService>
    {
        private Mock<IPersonaRepository> personaRepository;
        private Mock<IUsuarioRepository> usuarioRepository;
        private Mock<IBaseFactory> baseFactory;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IPasswordHasherDomainService> passwordHasherDomainService;
        private Mock<IVerificacionEmailBusinessService> verificacionEmailBusinessService;
        private Mock<ILogger<CrearCuentaBusinessService>> logger;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.personaRepository = new Mock<IPersonaRepository>();
            this.usuarioRepository = new Mock<IUsuarioRepository>();
            this.baseFactory = new Mock<IBaseFactory>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.passwordHasherDomainService = new Mock<IPasswordHasherDomainService>();
            this.verificacionEmailBusinessService = new Mock<IVerificacionEmailBusinessService>();
            this.logger = new Mock<ILogger<CrearCuentaBusinessService>>();

            this.Target = new CrearCuentaBusinessService(this.unitOfWork.Object,
                                                         this.personaRepository.Object,
                                                         this.usuarioRepository.Object,
                                                         this.baseFactory.Object,
                                                         this.entityLoaderDomainService.Object,
                                                         this.passwordHasherDomainService.Object,
                                                         this.verificacionEmailBusinessService.Object,
                                                         this.logger.Object);
        }

        public class ElMetodo_Crear : CrearCuentaBusinessTest
        {
            private CrearCuentaCommand command;
            private Mock<Persona> persona;
            private Mock<Usuario> usuario;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<CrearCuentaCommand>(c => c.Email == "mail@algo.com");

                this.persona = new Mock<Persona>();
                this.usuario = new Mock<Usuario>();

                this.baseFactory.Setup(s => s.Crear<Persona>()).Returns(this.persona.Object);
                this.baseFactory.Setup(s => s.Crear<Usuario>()).Returns(this.usuario.Object);
            }

            private void Action()
            {
                this.Target.Crear(this.command);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_Persona_de_la_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<Persona>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_CrearModificar_de_la_Persona()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.persona.Verify(v => v.CrearModificar(It.IsAny<CrearModificarPersona>()), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_PersonaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaRepository.Verify(v => v.Add(this.persona.Object), Times.Once);
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
