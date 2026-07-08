using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.Salud.AlertasBienestar;
using CareWell.Global.Constantes.Salud;
using Moq;

namespace CareWell.Domain.Test.Salud.AlertasBienestar
{
    public class DetectorAnimoBajoSostenidoTest : TestClassBase<DetectorAnimoBajoSostenido>
    {
        private Mock<IBaseFactory> baseFactory;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.baseFactory = new Mock<IBaseFactory>();

            this.Target = new DetectorAnimoBajoSostenido(this.baseFactory.Object);
        }

        public class ElMetodo_Detectar : DetectorAnimoBajoSostenidoTest
        {
            private List<PersonaEstadoAnimo> estadosAnimo;
            private DateTime fechaReferencia;
            private Mock<AlertaBienestar> alertaBienestar;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.estadosAnimo = new List<PersonaEstadoAnimo>
                {
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Mal) && a.FechaHora == DateTime.Now),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.MuyMal) && a.FechaHora == DateTime.Now.AddHours(1)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Mal) && a.FechaHora == DateTime.Now.AddHours(2)),
                };

                this.fechaReferencia = DateTime.Now;

                this.alertaBienestar = new Mock<AlertaBienestar>();

                this.baseFactory.Setup(s => s.Crear<AlertaBienestar>()).Returns(this.alertaBienestar.Object);
            }

            private AlertaBienestar? Action()
            {
                return this.Target.Detectar(this.estadosAnimo,
                                            this.fechaReferencia);
            }

            [Fact]
            public void Si_la_cantidad_de_registros_de_animo_no_superan_el_minimo_retorna_null()
            {
                // Arrange
                this.estadosAnimo.Clear();

                for (int i = 1; i < ParametrosDeteccionBienestar.MinRegistrosConsecutivosAnimoBajo; i++)
                {
                    this.estadosAnimo.Add(Mock.Of<PersonaEstadoAnimo>());
                }

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void Si_dentro_de_los_registros_de_animo_alguno_de_ellos_fue_regular_o_mejor_retorna_null()
            {
                // Arrange
                Mock.Get(this.estadosAnimo.First()).Setup(s => s.EstadoAnimo).Returns(Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Regular));

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void Si_la_cantidad_de_dias_que_pasaron_entre_el_animo_bajo_mas_viejo_y_el_mas_nuevo_registrados_supera_a_la_cantidad_de_dias_maxima_a_evaluar_retorna_null()
            {
                // Arrange
                Mock.Get(this.estadosAnimo.Last()).Setup(s => s.FechaHora).Returns(this.estadosAnimo.First().FechaHora.AddDays(ParametrosDeteccionBienestar.DiasLapsoMaximoAnimoBajo + 1));

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_AlertaBienestar_de_la_Factory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<AlertaBienestar>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_RegistrarAnimoBajoSostenido_con_severidad_media_del_AlertaBienestar_si_los_animos_varian_entre_mal_y_muy_mal()
            {
                // Arrange
                Mock.Get(this.estadosAnimo.First().Persona).Setup(s => s.Nombre).Returns("Persona X");

                // Action
                this.Action();

                // Assert
                this.alertaBienestar.Verify(v => v.RegistrarAnimoBajoSostenido(SeveridadesAlertaBienestar.Media,
                                                                               this.estadosAnimo.First().Persona.Nombre,
                                                                               this.fechaReferencia), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_RegistrarAnimoBajoSostenido_con_severidad_alta_del_AlertaBienestar_si_los_animos_son_muy_mal()
            {
                // Arrange
                this.estadosAnimo = new List<PersonaEstadoAnimo>
                {
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.MuyMal) && a.FechaHora == DateTime.Now),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.MuyMal) && a.FechaHora == DateTime.Now.AddHours(1)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.MuyMal) && a.FechaHora == DateTime.Now.AddHours(2)),
                };
                Mock.Get(this.estadosAnimo.First().Persona).Setup(s => s.Nombre).Returns("Persona X");

                // Action
                this.Action();

                // Assert
                this.alertaBienestar.Verify(v => v.RegistrarAnimoBajoSostenido(SeveridadesAlertaBienestar.Alta,
                                                                               this.estadosAnimo.First().Persona.Nombre,
                                                                               this.fechaReferencia), Times.Once);
            }

            [Fact]
            public void Retorna_una_instancia_del_tipo_AlertaBienestar()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(typeof(AlertaBienestar), resultado?.GetType().BaseType);
            }
        }
    }
}
