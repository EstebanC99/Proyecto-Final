using CareWell.BusinessService.Salud;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Queries.Salud;
using CareWell.Repository.Salud;
using CareWell.Security;
using Moq;

namespace CareWell.BusinessService.Test.Salud
{
    public class ResumenSaludBusinessTest : BusinessTestClassBase<ResumenSaludBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
        private Mock<IResumenSaludRepository> resumenSaludRepository;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            this.resumenSaludRepository = new Mock<IResumenSaludRepository>();

            this.Target = new ResumenSaludBusinessService
            (
                this.unitOfWork.Object,
                this.userContext.Object,
                this.entityLoaderDomainService.Object,
                this.validadorPermisoAccion.Object,
                this.resumenSaludRepository.Object
            );
        }

        public class ElMetodo_Obtener : ResumenSaludBusinessTest
        {
            private ResumenSaludQuery query;
            private Persona persona;
            private Usuario usuarioLogueado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<ResumenSaludQuery>(q => q.PersonaID == 1);
                this.persona = Mock.Of<Persona>();
                this.usuarioLogueado = Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>());

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(this.usuarioLogueado);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Persona>(this.query.PersonaID)).Returns(this.persona);
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
            public void Llama_una_vez_al_metodo_Obtener_del_ResumenSaludRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.resumenSaludRepository.Verify(v => v.Obtener(this.query), Times.Once);
            }
        }
    }
}
