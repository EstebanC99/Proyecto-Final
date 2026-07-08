using CareWell.BusinessService.Salud;
using CareWell.DataViews.Salud;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Salud;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.Salud.AlertasBienestar;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Queries.Salud;
using CareWell.Repository.Salud;
using CareWell.Security;
using Moq;

namespace CareWell.BusinessService.Test.Salud
{
    public class AlertaBienestarBusinessTest : BusinessTestClassBase<AlertaBienestarBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
        private Mock<IDetectorAlertasBienestarDomainService> detectorAlertasBienestarDomainService;
        private Mock<IAlertaBienestarRepository> alertasBienestarRepository;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            this.detectorAlertasBienestarDomainService = new Mock<IDetectorAlertasBienestarDomainService>();
            this.alertasBienestarRepository = new Mock<IAlertaBienestarRepository>();

            this.Target = new AlertaBienestarBusinessService(
                this.userContext.Object,
                this.entityLoaderDomainService.Object,
                this.validadorPermisoAccion.Object,
                this.detectorAlertasBienestarDomainService.Object,
                this.alertasBienestarRepository.Object
            );
        }

        public class ElMetodo_Obtener : AlertaBienestarBusinessTest
        {
            private AlertaBienestarQuery query;
            private Persona persona;
            private Usuario usuarioLogueado;
            private Mock<AlertaBienestar> alertaBienestar;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<AlertaBienestarQuery>(q => q.PersonaID == 1);
                this.persona = Mock.Of<Persona>();
                this.usuarioLogueado = Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>());

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(this.usuarioLogueado);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Persona>(this.query.PersonaID)).Returns(this.persona);

                this.alertaBienestar = new Mock<AlertaBienestar>();

                this.detectorAlertasBienestarDomainService.Setup(s => s.Detectar(It.IsAny<DetectarAlertaBienestar>())).Returns(new List<AlertaBienestar> { this.alertaBienestar.Object });
            }

            private List<AlertaBienestarDataView> Action()
            {
                return this.Target.Obtener(this.query);
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
            public void Llama_una_vez_al_metodo_GetEstadosAnimo_del_AlertaBienestarRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.alertasBienestarRepository.Verify(v => v.GetEstadosAnimo(this.query.PersonaID, It.IsAny<DateTime>()), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetHabitosActivos_del_AlertaBienestarRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.alertasBienestarRepository.Verify(v => v.GetHabitosActivos(this.query.PersonaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Detectar_del_DetectorAlertasBienestarDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.detectorAlertasBienestarDomainService.Verify(v => v.Detectar(It.IsAny<DetectarAlertaBienestar>()), Times.Once);
            }

            [Fact]
            public void Mapea_el_tipo_de_la_alerta_en_la_respuesta()
            {
                // Arrange
                this.alertaBienestar.Setup(s => s.Tipo).Returns("Tipo X");

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(resultado.First().Tipo, this.alertaBienestar.Object.Tipo);
            }

            [Fact]
            public void Mapea_la_severidad_de_la_alerta_en_la_respuesta()
            {
                // Arrange
                this.alertaBienestar.Setup(s => s.Severidad).Returns("Tipo X");

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(resultado.First().Severidad, this.alertaBienestar.Object.Severidad);
            }

            [Fact]
            public void Mapea_la_categoria_de_la_alerta_en_la_respuesta()
            {
                // Arrange
                this.alertaBienestar.Setup(s => s.Categoria).Returns("Tipo X");

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(resultado.First().Categoria, this.alertaBienestar.Object.Categoria);
            }

            [Fact]
            public void Mapea_el_mensaje_de_la_alerta_en_la_respuesta()
            {
                // Arrange
                this.alertaBienestar.Setup(s => s.Mensaje).Returns("Tipo X");

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(resultado.First().Mensaje, this.alertaBienestar.Object.Mensaje);
            }

            [Fact]
            public void Mapea_la_fecha_deteccion_de_la_alerta_en_la_respuesta()
            {
                // Arrange
                this.alertaBienestar.Setup(s => s.FechaDeteccion).Returns(DateTime.Now);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(resultado.First().FechaDeteccion, this.alertaBienestar.Object.FechaDeteccion);
            }

            [Fact]
            public void Mapea_el_id_del_habito_de_vida_de_la_alerta_en_la_respuesta()
            {
                // Arrange
                this.alertaBienestar.Setup(s => s.HabitoVida).Returns(Mock.Of<HabitoVida>(h => h.ID == 99));

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(resultado.First().HabitoVidaID, this.alertaBienestar.Object.HabitoVida?.ID);
            }

            [Fact]
            public void Retorna_una_instancia_del_tipo_List_AlertaBienestarDataView()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<List<AlertaBienestarDataView>>(resultado);
            }
        }
    }
}
