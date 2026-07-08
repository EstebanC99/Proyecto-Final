using CareWell.Domain.Salud;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Salud
{
    public class FichaSaludEnfermedadTest : TestClassBase<FichaSaludEnfermedad>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new FichaSaludEnfermedad();
        }

        public class ElMetodo_Registrar : FichaSaludEnfermedadTest
        {
            private AgregarEnfermedad agregarEnfermedad;
            private Mock<FichaSalud> fichaSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.agregarEnfermedad = new AgregarEnfermedad(
                    ID: 0,
                    Nombre: "Enfermedad X",
                    Vigente: true,
                    Observacion: "Obs"
                );

                this.fichaSalud = new Mock<FichaSalud>();
            }

            private void Action()
            {
                this.Target.Registrar(this.agregarEnfermedad,
                                      this.fichaSalud.Object);
            }

            [Fact]
            public void Si_el_Nombre_es_nulo_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.agregarEnfermedad = this.agregarEnfermedad with { Nombre = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NombreEnfermedadRequerido, exception.Message);
            }

            [Fact]
            public void Setea_la_propiedad_FichaSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.fichaSalud.Object, this.Target.FichaSalud);
            }

            [Fact]
            public void Setea_la_propiedad_Nombre()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.agregarEnfermedad.Nombre, this.Target.Nombre);
            }

            [Fact]
            public void Setea_la_propiedad_Vigente()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.agregarEnfermedad.Vigente, this.Target.Vigente);
            }

            [Fact]
            public void Setea_la_propiedad_Observacion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.agregarEnfermedad.Observacion, this.Target.Observacion);
            }
        }
    }
}
