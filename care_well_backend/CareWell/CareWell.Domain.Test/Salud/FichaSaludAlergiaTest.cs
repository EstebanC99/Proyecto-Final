using CareWell.Domain.Salud;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Salud
{
    public class FichaSaludAlergiaTest : TestClassBase<FichaSaludAlergia>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new FichaSaludAlergia();
        }

        public class ElMetodo_Registrar : FichaSaludAlergiaTest
        {
            private AgregarAlergia agregarAlergia;
            private Mock<FichaSalud> fichaSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.agregarAlergia = new AgregarAlergia(
                    ID: 0,
                    Nombre: "Enfermedad X",
                    Reaccion: "Reaccion Y",
                    Medicamento: "Medicamento Z"
                );

                this.fichaSalud = new Mock<FichaSalud>();
            }

            private void Action()
            {
                this.Target.Registrar(this.agregarAlergia,
                                      this.fichaSalud.Object);
            }

            [Fact]
            public void Si_el_Nombre_es_nulo_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.agregarAlergia = this.agregarAlergia with { Nombre = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NombreAlergiaRequerido, exception.Message);
            }

            [Fact]
            public void Si_la_Reaccion_es_nulo_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.agregarAlergia = this.agregarAlergia with { Reaccion = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ReaccionAlergiaRequerido, exception.Message);
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
                Assert.Equal(this.agregarAlergia.Nombre, this.Target.Nombre);
            }

            [Fact]
            public void Setea_la_propiedad_Reaccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.agregarAlergia.Reaccion, this.Target.Reaccion);
            }

            [Fact]
            public void Setea_la_propiedad_Medicamento()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.agregarAlergia.Medicamento, this.Target.Medicamento);
            }
        }
    }
}
