using CareWell.BusinessService.Agenda;
using CareWell.Domain.DomainServices.Agenda;
using CareWell.Domain.ValueObjects.Agenda;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.BusinessService.Test.Agenda
{
    public class ExpansorRecurrenciaBusinessTest : BusinessTestClassBase<ExpansorRecurrenciaBusinessService>
    {
        private Mock<ISerializadorFechasExceptuadasDomainService> serializadorFechasExceptuadasDomainService;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.serializadorFechasExceptuadasDomainService = new Mock<ISerializadorFechasExceptuadasDomainService>();

            this.Target = new ExpansorRecurrenciaBusinessService(this.serializadorFechasExceptuadasDomainService.Object);
        }

        public class ElMetodo_ConstruirRegla : ExpansorRecurrenciaBusinessTest
        {
            private DefinirRecurrenciaEventoAgenda definirRecurrencia;
            private DateTime fechaHoraInicio;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.definirRecurrencia = new DefinirRecurrenciaEventoAgenda
                (
                    FrecuenciaRecurrencia: Global.Enumeraciones.Agenda.FrecuenciaRecurrenciaEnum.Diaria,
                    Intervalo: 2,
                    FechaFin: null
                );

                this.fechaHoraInicio = DateTime.Now;
            }

            private string Action()
            {
                return this.Target.ConstruirRegla(this.definirRecurrencia,
                                                  this.fechaHoraInicio);
            }

            [Fact]
            public void Si_el_Intervalo_es_menor_a_1_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.definirRecurrencia = this.definirRecurrencia with { Intervalo = 0 };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ReglaRecurrenciaInvalida, exception.Message);
            }

            [Fact]
            public void Si_la_FechaFin_tiene_valor_y_es_menor_a_la_FechaaHoraInicio_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.definirRecurrencia = this.definirRecurrencia with { FechaFin = this.fechaHoraInicio.AddMinutes(-1) };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.FechaFinRecurrenciaInvalida, exception.Message);
            }

            [Fact]
            public void Retorna_un_string_con_tal_formato()
            {
                // Arrange
                var esperado = "FREQ=DAILY;INTERVAL=2";

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Contains(esperado, resultado);
            }

            [Fact]
            public void Retorna_un_string()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<string>(resultado);
            }
        }

        public class ElMetodo_EsReglaValida : ExpansorRecurrenciaBusinessTest
        {
            private string regla;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.regla = "FREQ=DAILY;INTERVAL=2";
            }

            private bool Action()
            {
                return this.Target.EsReglaValida(this.regla);
            }

            [Fact]
            public void Retorna_true_si_logra_convertir_la_regla_en_un_patron_de_recurrencia()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.True(resultado);
            }

            [Fact]
            public void Retorna_false_si_no_logra_convertir_la_regla_en_un_patron_de_recurrencia()
            {
                // Arrange
                this.regla = "ReglaX";

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }
        }

        public class ElMetodo_ExpandirOcurrencias : ExpansorRecurrenciaBusinessTest
        {
            private string regla;
            private DateTime inicioBase;
            private string? excepciones;
            private DateTime desde;
            private DateTime hasta;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.regla = "FREQ=DAILY;INTERVAL=1";
                this.inicioBase = DateTime.Today.AddMonths(-1);
                this.excepciones = null;

                this.desde = DateTime.Today.AddDays(-5);
                this.hasta = DateTime.Today.AddDays(5);
            }

            private List<DateTime> Action()
            {
                return this.Target.ExpandirOcurrencias(this.regla,
                                                       this.inicioBase,
                                                       this.excepciones,
                                                       this.desde,
                                                       this.hasta);
            }

            [Fact]
            public void Si_existen_fechas_exceptuadas_llama_una_vez_al_metodo_DeserializarFechasExceptuadas_del_serializadorFechasExceptuadasDomainService()
            {
                // Arrange
                this.excepciones = DateTime.Today.ToString();
                this.serializadorFechasExceptuadasDomainService.Setup(x => x.DeserializarFechasExceptuadas(this.excepciones)).Returns(new List<DateTime> { DateTime.Today });

                // Action
                var resultado = this.Action();

                // Assert
                this.serializadorFechasExceptuadasDomainService.Verify(x => x.DeserializarFechasExceptuadas(this.excepciones), Times.Once);
            }

            [Fact]
            public void Retora_una_lista_de_fechas_sin_incluir_las_exceptuadas()
            {
                // Arrange
                var fechaExceptuada = DateTime.Today;
                this.excepciones = fechaExceptuada.ToString();
                this.serializadorFechasExceptuadasDomainService.Setup(x => x.DeserializarFechasExceptuadas(this.excepciones)).Returns(new List<DateTime> { fechaExceptuada });

                // Action
                var resultado = this.Action();

                // Assert
                Assert.DoesNotContain(fechaExceptuada, resultado);
            }

            [Fact]
            public void Retora_una_lista_de_fechas_sin_incluir_la_fecha_hasta()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.DoesNotContain(this.hasta, resultado);
            }

            [Fact]
            public void Retora_una_lista_de_fechas_incluiyendo_la_fecha_desde()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Contains(this.desde, resultado);
            }

            [Fact]
            public void Retora_una_lista_de_fechas()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<List<DateTime>>(resultado);
            }
        }
    }
}
