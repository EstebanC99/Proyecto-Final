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
    public class AdministrarEventoSaludBusinessTest : BusinessTestClassBase<AdministrarEventoSaludBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IEventoSaludRepository> eventoSaludRepository;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
        private Mock<IBaseFactory> baseFactory;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.eventoSaludRepository = new Mock<IEventoSaludRepository>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            this.baseFactory = new Mock<IBaseFactory>();

            this.Target = new AdministrarEventoSaludBusinessService(
                this.unitOfWork.Object,
                this.userContext.Object,
                this.eventoSaludRepository.Object,
                this.entityLoaderDomainService.Object,
                this.validadorPermisoAccion.Object,
                this.baseFactory.Object
            );
        }

        public class ElMetodo_ObtenerTodos : AdministrarEventoSaludBusinessTest
        {
            private EventoSaludQuery query;
            private Persona persona;
            private Usuario usuarioLogueado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<EventoSaludQuery>(q => q.PersonaID == 1);
                this.persona = Mock.Of<Persona>();
                this.usuarioLogueado = Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>());

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(this.usuarioLogueado);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Persona>(this.query.PersonaID)).Returns(this.persona);
            }

            private void Action()
            {
                this.Target.ObtenerTodos(this.query);
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
            public void Llama_una_vez_al_metodo_ObtenerTodos_del_EventoSaludRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSaludRepository.Verify(v => v.ObtenerTodos(this.query), Times.Once);
            }
        }

        public class ElMetodo_Crear : AdministrarEventoSaludBusinessTest
        {
            private CrearEventoSaludCommand command;
            private Mock<EventoSalud> eventoSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<CrearEventoSaludCommand>(c =>
                    c.PersonaID == 1 &&
                    c.TipoID == 2
                );

                this.eventoSalud = new Mock<EventoSalud>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.baseFactory.Setup(s => s.Crear<EventoSalud>()).Returns(this.eventoSalud.Object);
            }

            private void Action()
            {
                this.Target.Crear(this.command);
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
            public void Llama_una_vez_al_metodo_GetByID_TipoEvento_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<TipoEvento>(this.command.TipoID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_EventoSalud_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<EventoSalud>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_del_EventoSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSalud.Verify(v => v.Crear(It.IsAny<CrearEventoSalud>(),
                                                     this.validadorPermisoAccion.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_EventoSaludRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSaludRepository.Verify(v => v.Add(this.eventoSalud.Object), Times.Once);
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

        public class ElMetodo_Eliminar : AdministrarEventoSaludBusinessTest
        {
            private int eventoAgendaID;
            private Mock<EventoSalud> eventoSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.eventoAgendaID = 1;

                this.eventoSalud = new Mock<EventoSalud>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.eventoSaludRepository.Setup(s => s.GetByID(this.eventoAgendaID)).Returns(this.eventoSalud.Object);
            }

            private void Action()
            {
                this.Target.Eliminar(this.eventoAgendaID);
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
            public void Llama_una_vez_al_metodo_GetByID_del_EventoSaludRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSaludRepository.Verify(v => v.GetByID(this.eventoAgendaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Eliminar_del_EventoSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSalud.Verify(v => v.Eliminar(It.IsAny<Persona>(),
                                                        this.validadorPermisoAccion.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Remove_del_EventoSaludRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSaludRepository.Verify(v => v.Remove(this.eventoSalud.Object), Times.Once);
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

        public class ElMetodo_AgregarNota : AdministrarEventoSaludBusinessTest
        {
            private CrearNotaEventoSaludCommand command;
            private Mock<EventoSalud> eventoSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<CrearNotaEventoSaludCommand>(c => c.EventoSaludID == 1);

                this.eventoSalud = new Mock<EventoSalud>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.eventoSaludRepository.Setup(s => s.GetByID(this.command.EventoSaludID)).Returns(this.eventoSalud.Object);
            }

            private void Action()
            {
                this.Target.AgregarNota(this.command);
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
            public void Llama_una_vez_al_metodo_GetByID_del_EventoSaludRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSaludRepository.Verify(v => v.GetByID(this.command.EventoSaludID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_AgregarNota_del_EventoSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSalud.Verify(v => v.AgregarNota(It.IsAny<CrearNotaEventoSalud>(),
                                                           this.validadorPermisoAccion.Object,
                                                           this.baseFactory.Object), Times.Once);
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

        public class ElMetodo_ModificarNota : AdministrarEventoSaludBusinessTest
        {
            private ModificarNotaEventoSaludCommand command;
            private Mock<EventoSalud> eventoSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<ModificarNotaEventoSaludCommand>(c => c.EventoSaludID == 1);

                this.eventoSalud = new Mock<EventoSalud>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.eventoSaludRepository.Setup(s => s.GetByID(this.command.EventoSaludID)).Returns(this.eventoSalud.Object);
            }

            private void Action()
            {
                this.Target.ModificarNota(this.command);
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
            public void Llama_una_vez_al_metodo_GetByID_del_EventoSaludRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSaludRepository.Verify(v => v.GetByID(this.command.EventoSaludID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ModificarNota_del_EventoSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSalud.Verify(v => v.ModificarNota(It.IsAny<ModificarNotaEventoSalud>(),
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

        public class ElMetodo_EliminarNota : AdministrarEventoSaludBusinessTest
        {
            private EliminarNotaEventoSaludCommand command;
            private Mock<EventoSalud> eventoSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<EliminarNotaEventoSaludCommand>(c => c.EventoSaludID == 1);

                this.eventoSalud = new Mock<EventoSalud>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.eventoSaludRepository.Setup(s => s.GetByID(this.command.EventoSaludID)).Returns(this.eventoSalud.Object);
            }

            private void Action()
            {
                this.Target.EliminarNota(this.command);
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
            public void Llama_una_vez_al_metodo_GetByID_del_EventoSaludRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSaludRepository.Verify(v => v.GetByID(this.command.EventoSaludID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_EliminarNota_del_EventoSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSalud.Verify(v => v.EliminarNota(It.IsAny<EliminarNotaEventoSalud>(),
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
    }
}
