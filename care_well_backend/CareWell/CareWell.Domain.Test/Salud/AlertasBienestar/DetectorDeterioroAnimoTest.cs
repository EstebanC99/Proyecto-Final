using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.Salud.AlertasBienestar;
using CareWell.Global.Constantes.Salud;
using Moq;

namespace CareWell.Domain.Test.Salud.AlertasBienestar
{
    public class DetectorDeterioroAnimoTest : TestClassBase<DetectorDeterioroAnimo>
    {
        private Mock<IBaseFactory> baseFactory;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.baseFactory = new Mock<IBaseFactory>();

            this.Target = new DetectorDeterioroAnimo(this.baseFactory.Object);
        }

        public class ElMetodo_Detectar : DetectorDeterioroAnimoTest
        {
            private List<PersonaEstadoAnimo> estadosAnimo;
            private DateTime fechaReferencia;
            private DateTime inicioReciente;
            private DateTime inicioBase;
            private Mock<AlertaBienestar> alertaBienestar;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.fechaReferencia = DateTime.Now;

                this.estadosAnimo = new List<PersonaEstadoAnimo>
                {
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Regular) && a.FechaHora == this.fechaReferencia.AddDays(-5)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Regular) && a.FechaHora == this.fechaReferencia.AddDays(-4)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Regular) && a.FechaHora == this.fechaReferencia.AddDays(-3)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Regular) && a.FechaHora == this.fechaReferencia.AddDays(-2)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Regular) && a.FechaHora == this.fechaReferencia.AddDays(-1)),

                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Mal) && a.FechaHora == this.fechaReferencia.AddHours(-3)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.MuyMal) && a.FechaHora == this.fechaReferencia.AddHours(-2)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Mal) && a.FechaHora == this.fechaReferencia.AddHours(-1)),
                };

                this.inicioReciente = this.fechaReferencia.AddHours(-4);
                this.inicioBase = this.fechaReferencia.AddDays(-6);

                this.alertaBienestar = new Mock<AlertaBienestar>();

                this.baseFactory.Setup(s => s.Crear<AlertaBienestar>()).Returns(this.alertaBienestar.Object);
            }

            private AlertaBienestar? Action()
            {
                return this.Target.Detectar(this.estadosAnimo,
                                            this.fechaReferencia,
                                            this.inicioReciente,
                                            this.inicioBase);
            }

            [Fact]
            public void Si_la_cantidad_de_registros_de_animo_recientes_es_menor_a_la_cantidad_minima_retorna_null()
            {
                // Arrange
                this.estadosAnimo = new List<PersonaEstadoAnimo>
                {
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Regular) && a.FechaHora == this.fechaReferencia.AddDays(-1)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Mal) && a.FechaHora == this.fechaReferencia.AddDays(-1)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.MuyMal) && a.FechaHora == this.fechaReferencia.AddHours(-1)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Mal) && a.FechaHora == this.fechaReferencia.AddMinutes(-1)),
                };

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void Si_la_cantidad_de_registros_de_animo_base_es_menor_a_la_cantidad_minima_retorna_null()
            {
                // Arrange
                this.estadosAnimo = new List<PersonaEstadoAnimo>
                {
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.MuyMal) && a.FechaHora == this.fechaReferencia.AddHours(-1)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Mal) && a.FechaHora == this.fechaReferencia.AddMinutes(-1)),
                };

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void Si_el_estado_de_animo_no_llego_a_deteriorarse_por_encima_del_delta_retorna_null()
            {
                // Arrange
                this.estadosAnimo = new List<PersonaEstadoAnimo>
                {
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Bien) && a.FechaHora == this.fechaReferencia.AddDays(-1)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Mal) && a.FechaHora == this.fechaReferencia.AddHours(-2)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.Bien) && a.FechaHora == this.fechaReferencia.AddHours(-1)),
                    Mock.Of<PersonaEstadoAnimo>(a => a.Persona == Mock.Of<Persona>() && a.EstadoAnimo == Mock.Of<EstadoAnimo>(e => e.ID == EstadosAnimo.MuyBien) && a.FechaHora == this.fechaReferencia.AddMinutes(-1)),
                };

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
            public void Llama_una_vez_al_metodo_RegistrarDeterioroAnimo_del_AlertaBienestar()
            {
                // Arrange
                Mock.Get(this.estadosAnimo.First().Persona).Setup(s => s.Nombre).Returns("Persona X");

                // Action
                this.Action();

                // Assert
                this.alertaBienestar.Verify(v => v.RegistrarDeterioroAnimo(this.estadosAnimo.First().Persona.Nombre,
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
