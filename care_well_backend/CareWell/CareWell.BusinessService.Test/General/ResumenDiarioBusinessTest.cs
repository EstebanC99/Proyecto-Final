using CareWell.BusinessService.Abstractions.General;
using CareWell.BusinessService.General;
using CareWell.DataViews.General;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Queries.General;
using CareWell.Security;
using Moq;

namespace CareWell.BusinessService.Test.General
{
    public class ResumenDiarioBusinessTest : BusinessTestClassBase<ResumenDiarioBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
        private Mock<IArmarResumenDiarioBusinessService> armarResumenDiarioBusinessService;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            this.armarResumenDiarioBusinessService = new Mock<IArmarResumenDiarioBusinessService>();

            this.Target = new ResumenDiarioBusinessService(
                this.unitOfWork.Object,
                this.userContext.Object,
                this.entityLoaderDomainService.Object,
                this.validadorPermisoAccion.Object,
                this.armarResumenDiarioBusinessService.Object
            );
        }

        public class ElMetodo_Generar : ResumenDiarioBusinessTest
        {
            private GenerarResumenDiarioQuery query;
            private Mock<Usuario> usuario;
            private Mock<Persona> personaCuidada;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<GenerarResumenDiarioQuery>(q => q.PersonaCuidadaID == 99);

                this.usuario = new Mock<Usuario>();
                this.usuario.Setup(s => s.ID).Returns(1);
                this.usuario.Setup(s => s.Persona).Returns(Mock.Of<Persona>());

                this.personaCuidada = new Mock<Persona>();
                this.personaCuidada.Setup(s => s.ID).Returns(this.query.PersonaCuidadaID);
                this.personaCuidada.Setup(s => s.Nombre).Returns("Persona X");

                this.userContext.Setup(s => s.UsuarioID).Returns(this.usuario.Object.ID);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(this.usuario.Object);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Persona>(It.IsAny<int>())).Returns(this.personaCuidada.Object);
            }

            private ResumenDiarioDataView Action()
            {
                return this.Target.Generar(this.query, It.IsAny<CancellationToken>()).Result;
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
                this.entityLoaderDomainService.Verify(v => v.GetByID<Persona>(this.query.PersonaCuidadaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarVisualizacion_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarVisualizacion(this.personaCuidada.Object, this.usuario.Object.Persona), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Armar_del_ArmarResumenDiarioBusinessService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.armarResumenDiarioBusinessService.Verify(v => v.Armar(this.personaCuidada.Object.ID, this.personaCuidada.Object.Nombre, It.IsAny<CancellationToken>()), Times.Once);
            }
        }
    }
}
