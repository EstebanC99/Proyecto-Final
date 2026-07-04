using CareWell.Domain.Salud;
using Moq;

namespace CareWell.Domain.Test.Salud
{
    public class HabitoVidaRealizacionTest : TestClassBase<HabitoVidaRealizacion>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new HabitoVidaRealizacion();
        }

        public class ElMetodo_Crear : HabitoVidaRealizacionTest
        {
            private Mock<HabitoVida> habitoVida;
            private string? comentarios;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.habitoVida = new Mock<HabitoVida>();

                this.comentarios = "X";
            }

            private void Action()
            {
                this.Target.Crear(this.habitoVida.Object,
                                  this.comentarios);
            }

            [Fact]
            public void Setea_la_propiedad_HabitoVida()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.habitoVida.Object, this.Target.HabitoVida);
            }

            [Fact]
            public void Setea_la_propiedad_FechaHoraRealizacion_con_la_actual()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(DateTime.Now.Date, this.Target.FechaHoraRealizacion.Date);
            }

            [Fact]
            public void Setea_la_propiedad_Comentarios()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.comentarios, this.Target.Comentarios);
            }
        }

        public class ElMetodo_Modificar : HabitoVidaRealizacionTest
        {
            private string? comentarios;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.comentarios = "X";
            }

            private void Action()
            {
                this.Target.Modificar(this.comentarios);
            }

            [Fact]
            public void Setea_la_propiedad_Comentarios()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.comentarios, this.Target.Comentarios);
            }
        }
    }
}
