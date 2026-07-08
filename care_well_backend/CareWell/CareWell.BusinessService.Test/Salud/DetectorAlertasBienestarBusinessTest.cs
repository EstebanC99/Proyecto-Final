using CareWell.BusinessService.Salud;
using CareWell.Domain.Salud;
using CareWell.Domain.Salud.AlertasBienestar;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Constantes.Salud;
using Moq;

namespace CareWell.BusinessService.Test.Salud
{
    public class DetectorAlertasBienestarBusinessTest : BusinessTestClassBase<DetectorAlertasBienestarBusinessService>
    {
        private Mock<IDetectorAnimoBajoSostenido> detectorAnimoBajoSostenido;
        private Mock<IDetectorDeterioroAnimo> detectorDeterioroAnimo;
        private Mock<IDetectorAlertaHabito> detectorAlertaHabito;

        public DetectorAlertasBienestarBusinessTest()
        {
            this.detectorAnimoBajoSostenido = new Mock<IDetectorAnimoBajoSostenido>();
            this.detectorDeterioroAnimo = new Mock<IDetectorDeterioroAnimo>();
            this.detectorAlertaHabito = new Mock<IDetectorAlertaHabito>();

            this.Target = new DetectorAlertasBienestarBusinessService(
                this.detectorAnimoBajoSostenido.Object,
                this.detectorDeterioroAnimo.Object,
                this.detectorAlertaHabito.Object
            );
        }

        public class ElMetodo_Detectar : DetectorAlertasBienestarBusinessTest
        {
            private DetectarAlertaBienestar detectarAlerta;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.detectarAlerta = new DetectarAlertaBienestar(
                    EstadosAnimo: new List<PersonaEstadoAnimo>(),
                    HabitosVida: new List<HabitoVida> { Mock.Of<HabitoVida>() },
                    FechaReferencia: DateTime.Now
                );
            }

            private List<AlertaBienestar> Action()
            {
                return this.Target.Detectar(this.detectarAlerta);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Detectar_del_DetectorAnimoBajoSostenido()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.detectorAnimoBajoSostenido.Verify(v => v.Detectar(this.detectarAlerta.EstadosAnimo,
                                                                       this.detectarAlerta.FechaReferencia), Times.Once);
            }

            [Fact]
            public void Agrega_la_AlertaBienestar_obtenida_por_el_DetectorAnimoBajoSostenido_a_la_respuesta()
            {
                // Arrange
                var alertaBienestar = Mock.Of<AlertaBienestar>();
                this.detectorAnimoBajoSostenido.Setup(v => v.Detectar(this.detectarAlerta.EstadosAnimo, this.detectarAlerta.FechaReferencia)).Returns(alertaBienestar);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Contains(alertaBienestar, resultado);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Detectar_del_DetectorDeterioroAnimo()
            {
                // Arrange
                var fechaVentanaReciente = this.detectarAlerta.FechaReferencia.AddDays(-ParametrosDeteccionBienestar.DiasVentanaReciente);
                var fechaVentanaBase = this.detectarAlerta.FechaReferencia.AddDays(-(ParametrosDeteccionBienestar.DiasVentanaReciente + ParametrosDeteccionBienestar.DiasVentanaBase));

                // Action
                this.Action();

                // Assert
                this.detectorDeterioroAnimo.Verify(v => v.Detectar(this.detectarAlerta.EstadosAnimo,
                                                                   this.detectarAlerta.FechaReferencia,
                                                                   fechaVentanaReciente,
                                                                   fechaVentanaBase), Times.Once);
            }

            [Fact]
            public void Agrega_la_AlertaBienestar_obtenida_por_el_DetectorDeterioroAnimo_a_la_respuesta()
            {
                // Arrange
                var alertaBienestar = Mock.Of<AlertaBienestar>();
                this.detectorDeterioroAnimo.Setup(v => v.Detectar(this.detectarAlerta.EstadosAnimo,
                                                                  this.detectarAlerta.FechaReferencia,
                                                                  It.IsAny<DateTime>(),
                                                                  It.IsAny<DateTime>())).Returns(alertaBienestar);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Contains(alertaBienestar, resultado);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Detectar_del_DetectorAlertaHabito()
            {
                // Arrange
                var fechaVentanaReciente = this.detectarAlerta.FechaReferencia.AddDays(-ParametrosDeteccionBienestar.DiasVentanaReciente);
                var fechaVentanaBase = this.detectarAlerta.FechaReferencia.AddDays(-(ParametrosDeteccionBienestar.DiasVentanaReciente + ParametrosDeteccionBienestar.DiasVentanaBase));

                // Action
                this.Action();

                // Assert
                this.detectorAlertaHabito.Verify(v => v.Detectar(this.detectarAlerta.HabitosVida.First(),
                                                                 this.detectarAlerta.FechaReferencia,
                                                                 fechaVentanaReciente,
                                                                 fechaVentanaBase), Times.Once);
            }

            [Fact]
            public void Agrega_la_AlertaBienestar_obtenida_por_el_DetectorAlertaHabito_a_la_respuesta()
            {
                // Arrange
                var alertaBienestar = Mock.Of<AlertaBienestar>();
                this.detectorAlertaHabito.Setup(v => v.Detectar(this.detectarAlerta.HabitosVida.First(),
                                                                this.detectarAlerta.FechaReferencia,
                                                                It.IsAny<DateTime>(),
                                                                It.IsAny<DateTime>())).Returns(alertaBienestar);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Contains(alertaBienestar, resultado);
            }

            [Fact]
            public void Retorna_una_lista_del_tipo_AlertaBienestar()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<List<AlertaBienestar>>(resultado);
            }
        }
    }
}
