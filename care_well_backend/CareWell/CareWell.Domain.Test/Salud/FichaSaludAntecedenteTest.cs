using CareWell.Domain.Salud;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Salud
{
    public class FichaSaludAntecedenteTest : TestClassBase<FichaSaludAntecedente>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new FichaSaludAntecedente();
        }

        public class ElMetodo_Registrar : FichaSaludAntecedenteTest
        {
            private AgregarAntecedente agregarAntecedente;
            private Mock<FichaSalud> fichaSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.agregarAntecedente = new AgregarAntecedente(
                    ID: 0,
                    Nombre: "Antecendete X",
                    Descripcion: "Desc del Antecedente",
                    VinculoFamiliar: "Parentezco Z"
                );

                this.fichaSalud = new Mock<FichaSalud>();
            }

            private void Action()
            {
                this.Target.Registrar(this.agregarAntecedente,
                                      this.fichaSalud.Object);
            }

            [Fact]
            public void Si_el_Nombre_es_nulo_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.agregarAntecedente = this.agregarAntecedente with { Nombre = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NombreAntecedenteRequerido, exception.Message);
            }

            [Fact]
            public void Si_la_Descripcion_es_nulo_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.agregarAntecedente = this.agregarAntecedente with { Descripcion = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.DescripcionAntecedenteRequerido, exception.Message);
            }

            [Fact]
            public void Si_el_VinculoFamiliar_es_nulo_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.agregarAntecedente = this.agregarAntecedente with { VinculoFamiliar = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.VinculoAntecedenteRequerido, exception.Message);
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
                Assert.Equal(this.agregarAntecedente.Nombre, this.Target.Nombre);
            }

            [Fact]
            public void Setea_la_propiedad_Descripcion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.agregarAntecedente.Descripcion, this.Target.Descripcion);
            }

            [Fact]
            public void Setea_la_propiedad_VinculoFamiliar()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.agregarAntecedente.VinculoFamiliar, this.Target.VinculoFamiliar);
            }
        }
    }
}
