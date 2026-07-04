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
    public class AdministrarHabitoVidaBusinessTest : BusinessTestClassBase<AdministrarHabitoVidaBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IHabitoVidaRepository> habitoVidaRepository;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IBaseFactory> baseFactory;
        private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.habitoVidaRepository = new Mock<IHabitoVidaRepository>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            this.baseFactory = new Mock<IBaseFactory>();

            this.Target = new AdministrarHabitoVidaBusinessService(
                this.unitOfWork.Object,
                this.userContext.Object,
                this.habitoVidaRepository.Object,
                this.entityLoaderDomainService.Object,
                this.baseFactory.Object,
                this.validadorPermisoAccion.Object
            );
        }

        public class ElMetodo_ObtenerTodos : AdministrarHabitoVidaBusinessTest
        {
            private HabitoVidaQuery query;
            private Persona persona;
            private Usuario usuarioLogueado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<HabitoVidaQuery>(q => q.PersonaID == 1);
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
            public void Llama_una_vez_al_metodo_ObtenerTodos_del_HabitoVidaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVidaRepository.Verify(v => v.ObtenerTodos(this.query), Times.Once);
            }
        }

        public class ElMetodo_ObtenerRealizacionesPorFecha : AdministrarHabitoVidaBusinessTest
        {
            private HabitoVidaQuery query;
            private Persona persona;
            private Usuario usuarioLogueado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<HabitoVidaQuery>(q => q.PersonaID == 1);
                this.persona = Mock.Of<Persona>();
                this.usuarioLogueado = Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>());

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(this.usuarioLogueado);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Persona>(this.query.PersonaID)).Returns(this.persona);
            }

            private void Action()
            {
                this.Target.ObtenerRealizacionesPorFecha(this.query);
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
            public void Llama_una_vez_al_metodo_ObtenerRealizacionesPorFecha_del_HabitoVidaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVidaRepository.Verify(v => v.ObtenerRealizacionesPorFecha(this.query), Times.Once);
            }
        }

        public class ElMetodo_Crear : AdministrarHabitoVidaBusinessTest
        {
            private CrearHabitoVidaCommand command;
            private Mock<HabitoVida> habitoVida;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<CrearHabitoVidaCommand>(c =>
                    c.PersonaID == 1 &&
                    c.TipoHabitoID == 2
                );

                this.habitoVida = new Mock<HabitoVida>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.baseFactory.Setup(s => s.Crear<HabitoVida>()).Returns(this.habitoVida.Object);
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
            public void Llama_una_vez_al_metodo_GetByID_TipoHabitoVida_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<TipoHabitoVida>(this.command.TipoHabitoID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_HabitoVida_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<HabitoVida>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_del_HabitoVida()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVida.Verify(v => v.Crear(It.IsAny<CrearHabitoVida>(),
                                                     this.validadorPermisoAccion.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_HabitoVidaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVidaRepository.Verify(v => v.Add(this.habitoVida.Object), Times.Once);
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

        public class ElMetodo_Modificar : AdministrarHabitoVidaBusinessTest
        {
            private ModificarHabitoVidaCommand command;
            private Mock<HabitoVida> habitoVida;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<ModificarHabitoVidaCommand>(c =>
                    c.HabitoVidaID == 1 &&
                    c.TipoHabitoID == 2
                );

                this.habitoVida = new Mock<HabitoVida>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.habitoVidaRepository.Setup(s => s.GetByID(this.command.HabitoVidaID)).Returns(this.habitoVida.Object);
            }

            private void Action()
            {
                this.Target.Modificar(this.command);
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
            public void Llama_una_vez_al_metodo_GetByID_del_HabitoVidarepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVidaRepository.Verify(v => v.GetByID(this.command.HabitoVidaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_TipoHabitoVida_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<TipoHabitoVida>(this.command.TipoHabitoID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Modificar_del_HabitoVida()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVida.Verify(v => v.Modificar(It.IsAny<ModificarHabitoVida>(),
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

        public class ElMetodo_Eliminar : AdministrarHabitoVidaBusinessTest
        {
            private int habitoVidaID;
            private Mock<HabitoVida> habitoVida;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.habitoVidaID = 1;

                this.habitoVida = new Mock<HabitoVida>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.habitoVidaRepository.Setup(s => s.GetByID(this.habitoVidaID)).Returns(this.habitoVida.Object);
            }

            private void Action()
            {
                this.Target.Eliminar(this.habitoVidaID);
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
            public void Llama_una_vez_al_metodo_GetByID_del_HabitoVidaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVidaRepository.Verify(v => v.GetByID(this.habitoVidaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Eliminar_del_HabitoVida()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVida.Verify(v => v.Eliminar(It.IsAny<Persona>(),
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

        public class ElMetodo_CrearRealizacion : AdministrarHabitoVidaBusinessTest
        {
            private CrearRealizacionHabitoVidaCommand command;
            private Mock<HabitoVida> habitoVida;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<CrearRealizacionHabitoVidaCommand>(c => c.HabitoVidaID == 1);

                this.habitoVida = new Mock<HabitoVida>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.habitoVidaRepository.Setup(s => s.GetByID(this.command.HabitoVidaID)).Returns(this.habitoVida.Object);
            }

            private void Action()
            {
                this.Target.CrearRealizacion(this.command);
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
            public void Llama_una_vez_al_metodo_GetByID_del_HabitoVidaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVidaRepository.Verify(v => v.GetByID(this.command.HabitoVidaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarVisualizacion_del_ValidadorPermisoAccion()
            {
                // Arrange
                this.habitoVida.Setup(s => s.Persona).Returns(Mock.Of<Persona>());
                var usuarioLogueado = Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>());
                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(usuarioLogueado);

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarVisualizacion(this.habitoVida.Object.Persona,
                                                                               usuarioLogueado.Persona), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_CrearRealizacion_del_HabitoVida()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVida.Verify(v => v.CrearRealizacion(this.command.Comentarios,
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

        public class ElMetodo_ModificarRealizacion : AdministrarHabitoVidaBusinessTest
        {
            private ModificarRealizacionHabitoVidaCommand command;
            private Mock<HabitoVida> habitoVida;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<ModificarRealizacionHabitoVidaCommand>(c => c.HabitoVidaID == 1);

                this.habitoVida = new Mock<HabitoVida>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.habitoVidaRepository.Setup(s => s.GetByID(this.command.HabitoVidaID)).Returns(this.habitoVida.Object);
            }

            private void Action()
            {
                this.Target.ModificarRealizacion(this.command);
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
            public void Llama_una_vez_al_metodo_GetByID_del_HabitoVidaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVidaRepository.Verify(v => v.GetByID(this.command.HabitoVidaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarVisualizacion_del_ValidadorPermisoAccion()
            {
                // Arrange
                this.habitoVida.Setup(s => s.Persona).Returns(Mock.Of<Persona>());
                var usuarioLogueado = Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>());
                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(usuarioLogueado);

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarVisualizacion(this.habitoVida.Object.Persona,
                                                                               usuarioLogueado.Persona), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ModificarRealizacion_del_HabitoVida()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVida.Verify(v => v.ModificarRealizacion(this.command.RealizacionID,
                                                                   this.command.Comentarios), Times.Once);
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

        public class ElMetodo_EliminarNota : AdministrarHabitoVidaBusinessTest
        {
            private EliminarRealizacionHabitoVidaCommand command;
            private Mock<HabitoVida> habitoVida;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<EliminarRealizacionHabitoVidaCommand>(c => c.HabitoVidaID == 1);

                this.habitoVida = new Mock<HabitoVida>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.habitoVidaRepository.Setup(s => s.GetByID(this.command.HabitoVidaID)).Returns(this.habitoVida.Object);
            }

            private void Action()
            {
                this.Target.EliminarRealizacion(this.command);
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
            public void Llama_una_vez_al_metodo_GetByID_del_HabitoVidaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVidaRepository.Verify(v => v.GetByID(this.command.HabitoVidaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarVisualizacion_del_ValidadorPermisoAccion()
            {
                // Arrange
                this.habitoVida.Setup(s => s.Persona).Returns(Mock.Of<Persona>());
                var usuarioLogueado = Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>());
                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(usuarioLogueado);

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarVisualizacion(this.habitoVida.Object.Persona,
                                                                               usuarioLogueado.Persona), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_EliminarRealizacion_del_HabitoVida()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVida.Verify(v => v.EliminarRealizacion(this.command.RealizacionID), Times.Once);
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
