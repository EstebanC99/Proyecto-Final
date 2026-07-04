using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Salud
{
    public class PersonaEstadoAnimoTest : TestClassBase<PersonaEstadoAnimo>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new PersonaEstadoAnimo();
        }

        public class ElMetodo_Registrar : PersonaEstadoAnimoTest
        {
            private RegistrarEstadoAnimo registrarEstadoAnimo;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.registrarEstadoAnimo = new RegistrarEstadoAnimo(
                    Persona: Mock.Of<Persona>(),
                    Colaborador: Mock.Of<Persona>(),
                    EstadoAnimo: Mock.Of<EstadoAnimo>(),
                    Observaciones: "Estado de animo X"
                );

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            }

            private void Action()
            {
                this.Target.Registrar(this.registrarEstadoAnimo,
                                      this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Si_la_Persona_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.registrarEstadoAnimo = this.registrarEstadoAnimo with { Persona = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.PersonaNoExiste, excepcionEsperada.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarVisualizacion_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarVisualizacion(this.registrarEstadoAnimo.Persona, this.registrarEstadoAnimo.Colaborador), Times.Once);
            }

            [Fact]
            public void Si_el_EstadoAnimo_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.registrarEstadoAnimo = this.registrarEstadoAnimo with { EstadoAnimo = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.EstadoAnimoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Setea_la_propiedad_Persona()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.registrarEstadoAnimo.Persona, this.Target.Persona);
            }

            [Fact]
            public void Setea_la_propiedad_FechaHora_con_la_actual()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(DateTime.Today, this.Target.FechaHora.Date);
            }

            [Fact]
            public void Setea_la_propiedad_EstadoAnimo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.registrarEstadoAnimo.EstadoAnimo, this.Target.EstadoAnimo);
            }

            [Fact]
            public void Setea_la_propiedad_Observaciones()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarEstadoAnimo.Observaciones, this.Target.Observaciones);
            }
        }
    }
}
