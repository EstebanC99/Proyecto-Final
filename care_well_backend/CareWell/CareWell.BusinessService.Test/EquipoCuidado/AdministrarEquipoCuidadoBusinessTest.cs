using CareWell.BusinessService.EquipoCuidado;
using CareWell.Commands.EquipoCuidado;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.ValueObjects.EquipoCuidado;
using CareWell.Domain.ValueObjects.General;
using CareWell.Repository.EquipoCuidado;
using CareWell.Repository.General;
using CareWell.Security;
using Moq;

namespace CareWell.BusinessService.Test.EquipoCuidado
{
    public class AdministrarEquipoCuidadoBusinessTest : BusinessTestClassBase<AdministrarEquipoCuidadoBusinessService>
    {
        private Mock<IBaseFactory> baseFactory;
        private Mock<IUserContext> userContext;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IPersonaRepository> personaRepository;
        private Mock<IAsignacionCuidadoRepository> asignacionCuidadoRepository;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.baseFactory = new Mock<IBaseFactory>();
            this.userContext = new Mock<IUserContext>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.personaRepository = new Mock<IPersonaRepository>();
            this.asignacionCuidadoRepository = new Mock<IAsignacionCuidadoRepository>();

            this.Target = new AdministrarEquipoCuidadoBusinessService(this.unitOfWork.Object,
                                                                      this.baseFactory.Object,
                                                                      this.userContext.Object,
                                                                      this.entityLoaderDomainService.Object,
                                                                      this.personaRepository.Object,
                                                                      this.asignacionCuidadoRepository.Object);
        }

        public class ElMetodo_CrearPersonaCargo : AdministrarEquipoCuidadoBusinessTest
        {
            private CrearPersonaCargoCommand command;
            private Mock<Persona> personaCuidada;
            private Mock<AsignacionCuidado> asignacionCuidado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<CrearPersonaCargoCommand>();

                this.personaCuidada = new Mock<Persona>();
                this.asignacionCuidado = new Mock<AsignacionCuidado>();

                this.baseFactory.Setup(s => s.Crear<Persona>()).Returns(this.personaCuidada.Object);
                this.baseFactory.Setup(s => s.Crear<AsignacionCuidado>()).Returns(this.asignacionCuidado.Object);
            }

            private void Action()
            {
                this.Target.CrearPersonaCargo(this.command);
            }

            [Fact]
            public void Lee_el_UsuarioID_del_UserContext()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.userContext.Verify(v => v.UsuarioID, Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usario_del_EntityLoaderDomainService_con_el_UsuarioID_del_UserContext()
            {
                // Arrange
                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Usuario>(this.userContext.Object.UsuarioID), Times.Once);
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
            public void Llama_una_vez_al_metodo_Crear_de_la_Persona()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaCuidada.Verify(v => v.Crear(It.IsAny<CrearPersona>()), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_PersonaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaRepository.Verify(v => v.Add(this.personaCuidada.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_AsignacionCuidado_de_la_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<AsignacionCuidado>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_AsignarResponsable_de_la_AsignacionCuidado()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidado.Verify(v => v.AsignarResponsable(It.IsAny<CrearAsignacionResponsable>(),
                                                                        this.entityLoaderDomainService.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_AsignacionCuidadoRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidadoRepository.Verify(v => v.Add(this.asignacionCuidado.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_AsignarPermisosResponsable_de_la_AsignacionCuidado()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidado.Verify(v => v.AsignarPermisosResponsable(this.entityLoaderDomainService.Object), Times.Once);
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
