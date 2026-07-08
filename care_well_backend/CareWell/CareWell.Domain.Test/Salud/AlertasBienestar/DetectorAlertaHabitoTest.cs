using CareWell.Domain.Factories;
using CareWell.Domain.Salud;
using CareWell.Domain.Salud.AlertasBienestar;
using CareWell.Global.Constantes.Salud;
using Moq;

namespace CareWell.Domain.Test.Salud.AlertasBienestar
{
    public class DetectorAlertaHabitoTest : TestClassBase<DetectorAlertaHabito>
    {
        private Mock<IBaseFactory> baseFactory;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.baseFactory = new Mock<IBaseFactory>();

            this.Target = new DetectorAlertaHabito(this.baseFactory.Object);
        }

        public class ElMetodo_Detectar : DetectorAlertaHabitoTest
        {
            private HabitoVida habitoVida;
            private DateTime fechaReferencia;
            private DateTime inicioReciente;
            private DateTime inicioBase;
            private Mock<AlertaBienestar> alertaBienestar;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.fechaReferencia = DateTime.Now;

                this.habitoVida = Mock.Of<HabitoVida>(a =>
                    a.Activo == true &&
                    a.FechaCreacion == this.fechaReferencia.AddDays(-ParametrosDeteccionBienestar.DiasAntiguedadMinimaHabito) &&
                    a.Realizaciones == new List<HabitoVidaRealizacion>
                    {
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(1)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(2)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(3)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(4)),

                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioReciente.AddHours(1)),
                    }
                );

                this.inicioReciente = this.fechaReferencia.AddHours(-3);
                this.inicioBase = this.fechaReferencia.AddDays(-2);

                this.alertaBienestar = new Mock<AlertaBienestar>();

                this.baseFactory.Setup(s => s.Crear<AlertaBienestar>()).Returns(this.alertaBienestar.Object);
            }

            private AlertaBienestar? Action()
            {
                return this.Target.Detectar(this.habitoVida,
                                            this.fechaReferencia,
                                            this.inicioReciente,
                                            this.inicioBase);
            }

            [Fact]
            public void Si_el_habito_no_esta_activo_retorna_null()
            {
                // Arrange
                Mock.Get(this.habitoVida).Setup(s => s.Activo).Returns(false);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void Si_el_habito_tiene_menor_antiguedad_que_la_minima_retorna_null()
            {
                // Arrange
                Mock.Get(this.habitoVida).Setup(s => s.Realizaciones).Returns(new List<HabitoVidaRealizacion>
                    {
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(1)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(2)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(3)),

                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioReciente.AddHours(1)),
                    }
                );

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void Si_la_cantidad_de_realizaciones_base_es_menor_que_la_minima_retorna_null()
            {
                // Arrange
                Mock.Get(this.habitoVida).Setup(s => s.FechaCreacion).Returns(this.fechaReferencia.AddDays(-ParametrosDeteccionBienestar.DiasAntiguedadMinimaHabito + 1));

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void Si_no_hay_realizaciones_recientes_llama_una_vez_al_metodo_Crear_AlertaBienestar_de_la_Factory()
            {
                // Arrange
                Mock.Get(this.habitoVida).Setup(s => s.Realizaciones).Returns(new List<HabitoVidaRealizacion>
                    {
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(1)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(2)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(3)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(4)),
                    }
                );

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<AlertaBienestar>(), Times.Once);
            }

            [Fact]
            public void Si_no_hay_realizaciones_recientes_llama_una_vez_al_metodo_RegistrarAbandonoHabito_del_AlertaBienestar()
            {
                // Arrange
                Mock.Get(this.habitoVida).Setup(s => s.Realizaciones).Returns(new List<HabitoVidaRealizacion>
                    {
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(1)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(2)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(3)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(4)),
                    }
                );
                var ultimaRealizacion = this.habitoVida.Realizaciones.Max(r => r.FechaHoraRealizacion);
                var diasSinRegistrar = (int)(this.fechaReferencia.Date - ultimaRealizacion.Date).TotalDays;

                // Action
                this.Action();

                // Assert
                this.alertaBienestar.Verify(v => v.RegistrarAbandonoHabito(diasSinRegistrar,
                                                                           this.fechaReferencia,
                                                                           this.habitoVida), Times.Once);
            }

            [Fact]
            public void Si_no_hay_realizaciones_recientes_retorna_una_instancia_del_tipo_AlertaBienestar()
            {
                // Arrange
                Mock.Get(this.habitoVida).Setup(s => s.Realizaciones).Returns(new List<HabitoVidaRealizacion>
                    {
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(1)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(2)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(3)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(4)),
                    }
                );

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(typeof(AlertaBienestar), resultado?.GetType().BaseType);
            }

            [Fact]
            public void Si_la_tasa_de_realizaciones_de_esta_semana_es_menor_a_la_base_semanal_llama_una_vez_al_metodo_Crear_AlertaBienestar_de_la_Factory()
            {
                // Arrange
                Mock.Get(this.habitoVida).Setup(s => s.Realizaciones).Returns(new List<HabitoVidaRealizacion>
                    {
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(1)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(2)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(3)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(4)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(5)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(6)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(7)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(8)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(9)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(10)),

                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioReciente.AddHours(1)),
                    }
                );

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<AlertaBienestar>(), Times.Once);
            }

            [Fact]
            public void Si_la_tasa_de_realizaciones_de_esta_semana_es_menor_a_la_base_semanal_llama_una_vez_al_metodo_RegistrarCaidaCumplimientoHabito_del_AlertaBienestar()
            {
                // Arrange
                Mock.Get(this.habitoVida).Setup(s => s.Realizaciones).Returns(new List<HabitoVidaRealizacion>
                    {
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(1)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(2)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(3)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(4)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(5)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(6)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(7)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(8)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(9)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(10)),

                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioReciente.AddHours(1)),
                    }
                );

                // Action
                this.Action();

                // Assert
                this.alertaBienestar.Verify(v => v.RegistrarCaidaCumplimientoHabito(this.fechaReferencia,
                                                                                    this.habitoVida), Times.Once);
            }

            [Fact]
            public void Si_la_tasa_de_realizaciones_de_esta_semana_es_menor_a_la_base_semanal_retorna_una_instancia_del_tipo_AlertaBienestar()
            {
                // Arrange
                Mock.Get(this.habitoVida).Setup(s => s.Realizaciones).Returns(new List<HabitoVidaRealizacion>
                    {
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(1)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(2)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(3)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(4)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(5)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(6)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(7)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(8)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(9)),
                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioBase.AddHours(10)),

                        Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == this.inicioReciente.AddHours(1)),
                    }
                );

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(typeof(AlertaBienestar), resultado?.GetType().BaseType);
            }

            [Fact]
            public void En_cualquier_otro_caso_retorna_null()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }
        }
    }
}
