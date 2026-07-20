using CareWell.BusinessService.General;
using CareWell.Commands.General;
using CareWell.DataViews.General;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.General;
using CareWell.Repository.General;
using CareWell.Security;
using Moq;

namespace CareWell.BusinessService.Test.General
{
    public class AdministrarPersonaBusinessTest : BusinessTestClassBase<AdministrarPersonaBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
        private Mock<IPersonaRepository> personaRepository;
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            this.personaRepository = new Mock<IPersonaRepository>();

            this.Target = new AdministrarPersonaBusinessService(
                this.unitOfWork.Object,
                this.userContext.Object,
                this.entityLoaderDomainService.Object,
                this.validadorPermisoAccion.Object,
                this.personaRepository.Object
            );
        }

        public class ElMetodo_ModificarPerfil : AdministrarPersonaBusinessTest
        {
            private ModificarPerfilCommand command;
            private Mock<Persona> persona;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<ModificarPerfilCommand>(c => c.ID == 1);

                this.persona = new Mock<Persona>();

                this.personaRepository.Setup(s => s.GetByID(this.command.ID)).Returns(this.persona.Object);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>());
            }

            private void Action()
            {
                this.Target.ModificarPerfil(this.command);
            }

            [Fact]
            public void Lee_una_vez_el_UsuarioID_del_UserContext()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.userContext.Verify(v => v.UsuarioID, Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService_con_el_id_de_usuario_logueado()
            {
                // Arrange
                var usuarioID = 99;
                this.userContext.Setup(s => s.UsuarioID).Returns(usuarioID);

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Usuario>(usuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_del_PersonaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaRepository.Verify(v => v.GetByID(this.command.ID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ModificarPerfil_de_la_persona()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.persona.Verify(v => v.ModificarPerfil(It.IsAny<ModificarPerfil>(),
                                                           It.IsAny<Persona>(),
                                                           this.validadorPermisoAccion.Object), Times.Once);
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

        public class ElMetodo_ObtenerImagenPerfil : AdministrarPersonaBusinessTest
        {
            private readonly int personaID = 1;
            private Mock<Persona> persona;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.persona = new Mock<Persona>();
                this.persona.Setup(s => s.Imagen).Returns(new byte[8]);

                this.personaRepository.Setup(s => s.GetByID(this.personaID)).Returns(this.persona.Object);
            }

            private PersonaImagenDataView Action()
            {
                return this.Target.ObtenerImagenPerfil(this.personaID);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_del_PersonaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaRepository.Verify(v => v.GetByID(this.personaID), Times.Once);
            }

            [Fact]
            public void Setea_la_imagen_de_la_persona_en_la_respuesta()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.persona.Object.Imagen, resultado.Contenido);
            }

            [Fact]
            public void Retorna_una_instancia_de_la_clase_PersonaImagenDataView()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<PersonaImagenDataView>(resultado);
            }
        }
    }
}
