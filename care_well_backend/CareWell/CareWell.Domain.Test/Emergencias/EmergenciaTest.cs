using CareWell.Domain.Emergencias;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.General;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Emergencias
{
    public class EmergenciaTest : TestClassBase<Emergencia>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new Emergencia();
        }

        public class ElMetodo_Activar : EmergenciaTest
        {
            private ActivarEmergencia activarEmergencia;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.activarEmergencia = new ActivarEmergencia
                (
                    Persona: Mock.Of<Persona>(),
                    Activador: Mock.Of<Persona>(),
                    Descripcion: "Emergencia de prueba"
                );

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            }

            private void Action()
            {
                this.Target.Activar
                (
                    this.activarEmergencia,
                    this.validadorPermisoAccion.Object
                );
            }

            [Fact]
            public void Si_la_persona_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.activarEmergencia = this.activarEmergencia with { Persona = null };

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.PersonaNoExiste, excepcion.Message);
            }

            [Fact]
            public void Si_el_activador_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.activarEmergencia = this.activarEmergencia with { Activador = null };

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ActivadorEmergenciaRequerido, excepcion.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeActivarEmergencia_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeActivarEmergencia(this.activarEmergencia.Persona, this.activarEmergencia.Activador), Times.Once);
            }

            [Fact]
            public void Setea_la_propiedad_Persona()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.activarEmergencia.Persona, this.Target.Persona);
            }

            [Fact]
            public void Setea_la_propiedad_Activador()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.activarEmergencia.Activador, this.Target.Activador);
            }

            [Fact]
            public void Setea_la_propiedad_Descipcion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.activarEmergencia.Descripcion, this.Target.Descripcion);
            }

            [Fact]
            public void Setea_la_propiedad_FechaHora_con_la_actual()
            {
                // Arrange
                var fechaHoraInicioEjecucion = DateTime.Now;

                // Action
                this.Action();

                // Assert
                var fechaHoraFinEjecucion = DateTime.Now;
                Assert.True(this.Target.FechaHora >= fechaHoraInicioEjecucion && this.Target.FechaHora <= fechaHoraFinEjecucion);
            }
        }
    }
}
