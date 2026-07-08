using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.Salud.AlertasBienestar;
using CareWell.Global.Constantes.Salud;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Salud.AlertasBienestar
{
    public class AlertaBienestarTest : TestClassBase<AlertaBienestar>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new AlertaBienestar();
        }

        public class ElMetodo_RegistrarAnimoBajoSostenido : AlertaBienestarTest
        {
            private string severidad;
            private string nombrePersona;
            private DateTime fechaReferencia;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.severidad = SeveridadesAlertaBienestar.Media;
                this.nombrePersona = "Persona X";
                this.fechaReferencia = DateTime.Now;
            }

            private void Action()
            {
                this.Target.RegistrarAnimoBajoSostenido(this.severidad, this.nombrePersona, this.fechaReferencia);
            }

            [Fact]
            public void Setea_la_propiedad_Tipo_con_AnimoBajoSostenido()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(TiposAlertaBienestar.AnimoBajoSostenido, this.Target.Tipo);
            }

            [Fact]
            public void Setea_la_propiedad_Severidad()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.severidad, this.Target.Severidad);
            }

            [Fact]
            public void Setea_la_propiedad_Categoria_con_Animo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(CategoriasAlertaBienestar.Animo, this.Target.Categoria);
            }

            [Fact]
            public void Setea_la_propiedad_Mensaje()
            {
                // Arrange
                var mensajeEsperado = string.Format(Mensajes.AnimoBajoSostenido, this.nombrePersona, ParametrosDeteccionBienestar.MinRegistrosConsecutivosAnimoBajo);

                // Action
                this.Action();

                // Assert
                Assert.Equal(mensajeEsperado, this.Target.Mensaje);
            }

            [Fact]
            public void Setea_la_propiedad_FechaDeteccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.fechaReferencia, this.Target.FechaDeteccion);
            }
        }

        public class ElMetodo_RegistrarDeterioroAnimo : AlertaBienestarTest
        {
            private string nombrePersona;
            private DateTime fechaReferencia;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.nombrePersona = "Persona X";
                this.fechaReferencia = DateTime.Now;
            }

            private void Action()
            {
                this.Target.RegistrarDeterioroAnimo(this.nombrePersona, this.fechaReferencia);
            }

            [Fact]
            public void Setea_la_propiedad_Tipo_con_DeterioroAnimo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(TiposAlertaBienestar.DeterioroAnimo, this.Target.Tipo);
            }

            [Fact]
            public void Setea_la_propiedad_Severidad_con_Media()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(SeveridadesAlertaBienestar.Media, this.Target.Severidad);
            }

            [Fact]
            public void Setea_la_propiedad_Categoria_con_Animo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(CategoriasAlertaBienestar.Animo, this.Target.Categoria);
            }

            [Fact]
            public void Setea_la_propiedad_Mensaje()
            {
                // Arrange
                var mensajeEsperado = string.Format(Mensajes.DeterioroAnimo, nombrePersona);

                // Action
                this.Action();

                // Assert
                Assert.Equal(mensajeEsperado, this.Target.Mensaje);
            }

            [Fact]
            public void Setea_la_propiedad_FechaDeteccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.fechaReferencia, this.Target.FechaDeteccion);
            }
        }

        public class ElMetodo_RegistrarAbandonoHabito : AlertaBienestarTest
        {
            private int diasSinRegistrar;
            private DateTime fechaReferencia;
            private HabitoVida habitoVida;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.diasSinRegistrar = 5;
                this.fechaReferencia = DateTime.Now;
                this.habitoVida = Mock.Of<HabitoVida>(h => h.Persona == Mock.Of<Persona>(p => p.Nombre == "Persona X"));
            }

            private void Action()
            {
                this.Target.RegistrarAbandonoHabito(this.diasSinRegistrar, this.fechaReferencia, this.habitoVida);
            }

            [Fact]
            public void Setea_la_propiedad_Tipo_con_AbandonoHabito()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(TiposAlertaBienestar.AbandonoHabito, this.Target.Tipo);
            }

            [Fact]
            public void Setea_la_propiedad_Severidad_con_Alta()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(SeveridadesAlertaBienestar.Alta, this.Target.Severidad);
            }

            [Fact]
            public void Setea_la_propiedad_Categoria_con_Habito()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(CategoriasAlertaBienestar.Habito, this.Target.Categoria);
            }

            [Fact]
            public void Setea_la_propiedad_Mensaje()
            {
                // Arrange
                var mensajeEsperado = string.Format(Mensajes.AbandonoHabito, this.diasSinRegistrar, this.habitoVida.Descripcion, this.habitoVida.Persona.Nombre);

                // Action
                this.Action();

                // Assert
                Assert.Equal(mensajeEsperado, this.Target.Mensaje);
            }

            [Fact]
            public void Setea_la_propiedad_FechaDeteccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.fechaReferencia, this.Target.FechaDeteccion);
            }

            [Fact]
            public void Setea_la_propiedad_HabitoVida()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.habitoVida, this.Target.HabitoVida);
            }
        }

        public class ElMetodo_RegistrarCaidaCumplimientoHabito : AlertaBienestarTest
        {
            private DateTime fechaReferencia;
            private HabitoVida habitoVida;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.fechaReferencia = DateTime.Now;
                this.habitoVida = Mock.Of<HabitoVida>(h =>
                    h.Persona == Mock.Of<Persona>(p => p.Nombre == "Persona X") &&
                    h.Descripcion == "Habito U"
                );
            }

            private void Action()
            {
                this.Target.RegistrarCaidaCumplimientoHabito(this.fechaReferencia, this.habitoVida);
            }

            [Fact]
            public void Setea_la_propiedad_Tipo_con_CaidaCumplimiento()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(TiposAlertaBienestar.CaidaCumplimiento, this.Target.Tipo);
            }

            [Fact]
            public void Setea_la_propiedad_Severidad_con_Media()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(SeveridadesAlertaBienestar.Media, this.Target.Severidad);
            }

            [Fact]
            public void Setea_la_propiedad_Categoria_con_Habito()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(CategoriasAlertaBienestar.Habito, this.Target.Categoria);
            }

            [Fact]
            public void Setea_la_propiedad_Mensaje()
            {
                // Arrange
                var mensajeEsperado = string.Format(Mensajes.CaidaCumplimientoHabito, this.habitoVida.Descripcion, this.habitoVida.Persona.Nombre);

                // Action
                this.Action();

                // Assert
                Assert.Equal(mensajeEsperado, this.Target.Mensaje);
            }

            [Fact]
            public void Setea_la_propiedad_FechaDeteccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.fechaReferencia, this.Target.FechaDeteccion);
            }

            [Fact]
            public void Setea_la_propiedad_HabitoVida()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.habitoVida, this.Target.HabitoVida);
            }
        }
    }
}
