using CareWell.BusinessService.Emergencias;
using CareWell.Commands.Emergencias;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Emergencias;
using CareWell.Domain.Emergencias;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.General;
using CareWell.Queries.Emergencias;
using CareWell.Repository.Emergencias;
using CareWell.Security;
using Moq;

namespace CareWell.BusinessService.Test.Emergencias
{
    public class ActivarEmergenciaBusinessTest : BusinessTestClassBase<ActivarEmergenciaBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IBaseFactory> baseFactory;
        private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
        private Mock<IEmergenciaRepository> emergenciaRepository;
        private Mock<INotificarEmergenciaDomainService> notificarEmergenciaDomainService;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.baseFactory = new Mock<IBaseFactory>();
            this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            this.emergenciaRepository = new Mock<IEmergenciaRepository>();
            this.notificarEmergenciaDomainService = new Mock<INotificarEmergenciaDomainService>();

            this.Target = new ActivarEmergenciaBusinessService
            (
                this.unitOfWork.Object,
                this.userContext.Object,
                this.entityLoaderDomainService.Object,
                this.baseFactory.Object,
                this.validadorPermisoAccion.Object,
                this.emergenciaRepository.Object,
                this.notificarEmergenciaDomainService.Object
            );
        }

        public class ElMetodo_Obtener : ActivarEmergenciaBusinessTest
        {
            private ObtenerEmergenciasQuery query;
            private Mock<Usuario> usuario;
            private Mock<Persona> persona;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<ObtenerEmergenciasQuery>(q => q.PersonaID == 1);

                this.usuario = new Mock<Usuario>();
                this.usuario.Setup(s => s.Persona).Returns(Mock.Of<Persona>());

                this.persona = new Mock<Persona>();

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(this.usuario.Object);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Persona>(It.IsAny<int>())).Returns(this.persona.Object);
            }

            private void Action()
            {
                this.Target.Obtener(this.query);
            }

            [Fact]
            public void Lee_el_UsuarioID_del_UserContext()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.userContext.Verify(s => s.UsuarioID, Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(s => s.GetByID<Usuario>(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Persona_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(s => s.GetByID<Persona>(this.query.PersonaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarVisualizacion_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(s => s.ValidarVisualizacion(this.persona.Object, this.usuario.Object.Persona), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ObtenerPorPersona_del_EmergenciaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.emergenciaRepository.Verify(s => s.ObtenerPorPersona(this.query), Times.Once);
            }
        }

        public class ElMetodo_Activar : ActivarEmergenciaBusinessTest
        {
            private ActivarEmergenciaCommand command;

            private Mock<Usuario> usuario;
            private Mock<Persona> persona;

            private Mock<Emergencia> emergencia;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<ActivarEmergenciaCommand>(c =>
                    c.PersonaID == 1 &&
                    c.Descripcion == "DESC"
                );

                this.usuario = new Mock<Usuario>();
                this.usuario.Setup(s => s.Persona).Returns(Mock.Of<Persona>());

                this.persona = new Mock<Persona>();

                this.emergencia = new Mock<Emergencia>();

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(this.usuario.Object);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Persona>(It.IsAny<int>())).Returns(this.persona.Object);

                this.baseFactory.Setup(s => s.Crear<Emergencia>()).Returns(this.emergencia.Object);
            }

            private void Action()
            {
                this.Target.Activar(this.command, It.IsAny<CancellationToken>()).GetAwaiter().GetResult();
            }

            [Fact]
            public void Lee_el_UsuarioID_del_UserContext()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.userContext.Verify(s => s.UsuarioID, Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(s => s.GetByID<Usuario>(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Persona_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(s => s.GetByID<Persona>(this.command.PersonaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(s => s.Crear<Emergencia>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Activar_de_la_Emergencia()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.emergencia.Verify(s => s.Activar(It.Is<ActivarEmergencia>(a =>
                    a.Persona == this.persona.Object &&
                    a.Activador == this.usuario.Object.Persona &&
                    a.Descripcion == this.command.Descripcion
                ), this.validadorPermisoAccion.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_EmergenciaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.emergenciaRepository.Verify(s => s.Add(this.emergencia.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Notificar_del_NotificarEmergenciaDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.notificarEmergenciaDomainService.Verify(s => s.Notificar(this.emergencia.Object, It.IsAny<CancellationToken>()), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork_si_al_notificar_se_produce_un_error()
            {
                // Arrange
                this.notificarEmergenciaDomainService.Setup(s => s.Notificar(It.IsAny<Emergencia>(), It.IsAny<CancellationToken>())).Throws(new Exception());

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(s => s.SaveChanges(), Times.Once);
            }

            [Fact]
            public void Llama_dos_veces_al_metodo_SaveChanges_del_UnitOfWork_si_al_notificar_no_se_produce_un_error()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(s => s.SaveChanges(), Times.Exactly(2));
            }
        }
    }
}
