using CareWell.Domain.General;
using CareWell.Domain.ValueObjects.General;
using CareWell.Global.Constantes.General;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.General
{
    public class ResumenDiarioTest : TestClassBase<ResumenDiario>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new ResumenDiario();
        }

        public class ElMetodo_Generar : ResumenDiarioTest
        {
            private GenerarResumenDiario generarResumenDiario;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.generarResumenDiario = new GenerarResumenDiario
                (
                    Persona: Mock.Of<Persona>(),
                    Contenido: "Content",
                    FechaHoraGeneracion: DateTime.Now
                );
            }

            private void Action()
            {
                this.Target.Generar(this.generarResumenDiario);
            }

            [Fact]
            public void Si_la_Persona_es_null_arroja_una_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.generarResumenDiario = this.generarResumenDiario with { Persona = null };

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.PersonaNoExiste, excepcion.Message);
            }

            [Theory]
            [InlineData(null)]
            [InlineData("")]
            [InlineData(" ")]
            public void Si_el_Contenido_es_nulo_o_vacio_arroja_una_ValidacionDominioException_con_mensaje_informativo(string? contenido)
            {
                // Arrange
                this.generarResumenDiario = this.generarResumenDiario with { Contenido = contenido! };

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ResumenDiarioContenidoRequerido, excepcion.Message);
            }

            [Fact]
            public void Si_la_FechaHoraGeneracion_es_el_valor_por_defecto_arroja_una_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.generarResumenDiario = this.generarResumenDiario with { FechaHoraGeneracion = default };

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ResumenDiarioFechaGeneracionRequerida, excepcion.Message);
            }

            [Fact]
            public void Setea_la_propiedad_Persona()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.generarResumenDiario.Persona, this.Target.Persona);
            }

            [Fact]
            public void Setea_la_propiedad_Contenido()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.generarResumenDiario.Contenido, this.Target.Contenido);
            }

            [Fact]
            public void Setea_la_propiedad_FechaHoraGeneracion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.generarResumenDiario.FechaHoraGeneracion, this.Target.FechaHoraGeneracion);
            }
        }

        public class ElMetodo_EsReutilizable : ResumenDiarioTest
        {
            private bool forzarActualizacion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.forzarActualizacion = true;

                #region Generar

                var generarResumenDiario = new GenerarResumenDiario
                (
                    Persona: Mock.Of<Persona>(),
                    Contenido: "Content",
                    FechaHoraGeneracion: DateTime.Now.AddSeconds(-1)
                );

                this.Target.Generar(generarResumenDiario);

                #endregion
            }

            private bool Action()
            {
                return this.Target.EsReutilizable(this.forzarActualizacion);
            }

            [Fact]
            public void Retorna_true_si_ForzarActualizacion_es_true_y_no_paso_el_tiempo_minimo_entre_regeneraciones()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.True(resultado);
            }

            [Fact]
            public void Retorna_false_si_ForzarActualizacion_es_true_y_paso_el_tiempo_minimo_entre_regeneraciones()
            {
                // Arrange

                var generarResumenDiario = new GenerarResumenDiario
                (
                    Persona: Mock.Of<Persona>(),
                    Contenido: "Content",
                    FechaHoraGeneracion: DateTime.Now.AddMinutes(-ParametrosResumenDiario.MinutosMinimosEntreRegeneraciones)
                );

                this.Target.Generar(generarResumenDiario);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Retorna_false_si_el_parametro_ForzarActualizacion_es_false_y_la_FechaHoraGeneracion_es_mayor_a_la_actual()
            {
                // Arrange
                this.forzarActualizacion = false;

                var generarResumenDiario = new GenerarResumenDiario
                (
                    Persona: Mock.Of<Persona>(),
                    Contenido: "Content",
                    FechaHoraGeneracion: DateTime.Now.AddMinutes(1)
                );

                this.Target.Generar(generarResumenDiario);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Retorna_false_si_el_parametro_ForzarActualizacion_es_false_y_el_dia_de_la_FechaHoraGeneracion_es_diferente_al_actual()
            {
                // Arrange
                this.forzarActualizacion = false;

                var generarResumenDiario = new GenerarResumenDiario
                (
                    Persona: Mock.Of<Persona>(),
                    Contenido: "Content",
                    FechaHoraGeneracion: DateTime.Now.AddDays(1)
                );

                this.Target.Generar(generarResumenDiario);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Retorna_true_si_el_parametro_ForzarActualizacion_es_false_y_la_FechaHoraGeneracion_esta_dentro_de_la_vigencia()
            {
                // Arrange
                this.forzarActualizacion = false;

                var generarResumenDiario = new GenerarResumenDiario
                (
                    Persona: Mock.Of<Persona>(),
                    Contenido: "Content",
                    FechaHoraGeneracion: DateTime.Now
                );

                this.Target.Generar(generarResumenDiario);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.True(resultado);
            }

            [Fact]
            public void Retorna_false_si_el_parametro_ForzarActualizacion_es_false_y_la_FechaHoraGeneracion_no_esta_dentro_de_la_vigencia()
            {
                // Arrange
                this.forzarActualizacion = false;

                var generarResumenDiario = new GenerarResumenDiario
                (
                    Persona: Mock.Of<Persona>(),
                    Contenido: "Content",
                    FechaHoraGeneracion: DateTime.Now.AddHours(-ParametrosResumenDiario.HorasVigencia).AddMinutes(-1)
                );

                this.Target.Generar(generarResumenDiario);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }
        }
    }
}