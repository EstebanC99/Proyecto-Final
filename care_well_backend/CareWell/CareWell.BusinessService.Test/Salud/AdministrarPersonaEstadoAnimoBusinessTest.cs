using CareWell.BusinessService.Salud;
using CareWell.Commands.Salud;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Queries.Salud;
using CareWell.Repository.Salud;
using CareWell.Security;
using Moq;

namespace CareWell.BusinessService.Test.Salud
{
    public class AdministrarPersonaEstadoAnimoBusinessTest : BusinessTestClassBase<AdministrarPersonaEstadoAnimoBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IBaseFactory> baseFactory;
        private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
        private Mock<IPersonaEstadoAnimoRepository> personaEstadoAnimoRepository;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.baseFactory = new Mock<IBaseFactory>();
            this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            this.personaEstadoAnimoRepository = new Mock<IPersonaEstadoAnimoRepository>();

            this.Target = new AdministrarPersonaEstadoAnimoBusinessService(
                this.unitOfWork.Object,
                this.userContext.Object,
                this.entityLoaderDomainService.Object,
                this.baseFactory.Object,
                this.validadorPermisoAccion.Object,
                this.personaEstadoAnimoRepository.Object
            );
        }

        public class ElMetodo_ObtenerAnimoHoy : AdministrarPersonaEstadoAnimoBusinessTest
        {
            private PersonaEstadoAnimoHoyQuery query;
            private Persona persona;
            private Usuario usuarioLogueado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<PersonaEstadoAnimoHoyQuery>(q => q.PersonaID == 1);
                this.persona = Mock.Of<Persona>();
                this.usuarioLogueado = Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>());

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(this.usuarioLogueado);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Persona>(this.query.PersonaID)).Returns(this.persona);
            }

            private void Action()
            {
                this.Target.ObtenerAnimoHoy(this.query);
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
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Usuario>(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Persona_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Persona>(this.query.PersonaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarVisualizacion_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarVisualizacion(this.persona, this.usuarioLogueado.Persona), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ObtenerAnimoHoy_del_PersonaEstadoAnimoRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaEstadoAnimoRepository.Verify(v => v.ObtenerAnimoHoy(this.query), Times.Once);
            }
        }

        public class ElMetodo_ObtenerPorFechas : AdministrarPersonaEstadoAnimoBusinessTest
        {
            private PersonaEstadoAnimoPorFechaQuery query;
            private Persona persona;
            private Usuario usuarioLogueado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<PersonaEstadoAnimoPorFechaQuery>(q => q.PersonaID == 1);
                this.persona = Mock.Of<Persona>();
                this.usuarioLogueado = Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>());

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(this.usuarioLogueado);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Persona>(this.query.PersonaID)).Returns(this.persona);
            }

            private void Action()
            {
                this.Target.ObtenerPorFechas(this.query);
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
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Usuario>(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Persona_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Persona>(this.query.PersonaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarVisualizacion_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarVisualizacion(this.persona, this.usuarioLogueado.Persona), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ObtenerPorFechas_del_HabitoVidaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaEstadoAnimoRepository.Verify(v => v.ObtenerPorFechas(this.query), Times.Once);
            }
        }

        public class ElMetodo_Registrar : AdministrarPersonaEstadoAnimoBusinessTest
        {
            private RegistrarEstadoAnimoCommand command;
            private Mock<PersonaEstadoAnimo> personaEstadoAnimo;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<RegistrarEstadoAnimoCommand>(c =>
                    c.PersonaID == 1 &&
                    c.EstadoAnimoID == 2
                );

                this.personaEstadoAnimo = new Mock<PersonaEstadoAnimo>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.baseFactory.Setup(s => s.Crear<PersonaEstadoAnimo>()).Returns(this.personaEstadoAnimo.Object);
            }

            private void Action()
            {
                this.Target.Registrar(this.command);
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
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Usuario>(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Persona_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Persona>(this.command.PersonaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_EstadoAnimo_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<EstadoAnimo>(this.command.EstadoAnimoID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_PersonaEstadoAnimo_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<PersonaEstadoAnimo>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Registrar_del_PersonaEstadoAnimo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaEstadoAnimo.Verify(v => v.Registrar(It.IsAny<RegistrarEstadoAnimo>(),
                                                                this.validadorPermisoAccion.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_HabitoVidaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaEstadoAnimoRepository.Verify(v => v.Add(this.personaEstadoAnimo.Object), Times.Once);
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
