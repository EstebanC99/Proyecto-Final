using CareWell.Domain.Auditoria;
using CareWell.Domain.ValueObjects.Auditoria;
using CareWell.Global.Constantes.Auditoria;
using CareWell.Global.Extensions;

namespace CareWell.Domain.Test.Auditoria
{
    public class LogExcepcionTest : TestClassBase<LogExcepcion>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new LogExcepcion();
        }

        public class ElMetodo_Registrar : LogExcepcionTest
        {
            private RegistrarLogExcepcion registrarLogExcepcion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.registrarLogExcepcion = new RegistrarLogExcepcion
                (
                    Tipo: "Tipo X",
                    Controlada: true,
                    Mensaje: "Mensaje Error",
                    StackTrace: "Stacktrace X",
                    Ruta: "Ruta ASD",
                    Verbo: "POST",
                    TraceIdentifier: "Traza 123",
                    UsuarioID: 1
                );
            }

            private void Action()
            {
                this.Target.Registrar(this.registrarLogExcepcion);
            }

            [Fact]
            public void Setea_la_propiedad_Tipo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogExcepcion.Tipo, this.Target.Tipo);
            }

            [Fact]
            public void Si_el_tipo_es_mayor_a_la_LongitudMaximaTipo_establecida_la_trunca()
            {
                // Arrange
                var tipoLargo = "Tipo para exceder el largo";

                for (int i = 1; i <= ParametrosLogExcepcion.LongitudMaximaTipo; i++)
                {
                    tipoLargo += "A";
                }

                this.registrarLogExcepcion = this.registrarLogExcepcion with { Tipo = tipoLargo };

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogExcepcion.Tipo.Truncate(ParametrosLogExcepcion.LongitudMaximaTipo), this.Target.Tipo);
            }

            [Fact]
            public void Setea_la_propiedad_Controlada()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogExcepcion.Controlada, this.Target.Controlada);
            }

            [Fact]
            public void Setea_la_propiedad_Mensaje()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogExcepcion.Mensaje, this.Target.Mensaje);
            }

            [Fact]
            public void Si_el_mensaje_es_mayor_a_la_LongitudMaximaMensaje_establecida_la_trunca()
            {
                // Arrange
                var mensajeLargo = "Mensaje para exceder el largo";

                for (int i = 1; i <= ParametrosLogExcepcion.LongitudMaximaMensaje; i++)
                {
                    mensajeLargo += "A";
                }

                this.registrarLogExcepcion = this.registrarLogExcepcion with { Mensaje = mensajeLargo };

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogExcepcion.Mensaje.Truncate(ParametrosLogExcepcion.LongitudMaximaMensaje), this.Target.Mensaje);
            }

            [Fact]
            public void Setea_la_propiedad_StackTrace()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogExcepcion.StackTrace, this.Target.StackTrace);
            }

            [Fact]
            public void Setea_la_propiedad_Ruta()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogExcepcion.Ruta, this.Target.Ruta);
            }

            [Fact]
            public void Si_la_ruta_es_mayor_a_la_LongitudMaximaRuta_establecida_la_trunca()
            {
                // Arrange
                var rutaLarga = "Ruta para exceder el largo";

                for (int i = 1; i <= ParametrosLogExcepcion.LongitudMaximaRuta; i++)
                {
                    rutaLarga += "A";
                }

                this.registrarLogExcepcion = this.registrarLogExcepcion with { Ruta = rutaLarga };

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogExcepcion.Ruta.Truncate(ParametrosLogExcepcion.LongitudMaximaRuta), this.Target.Ruta);
            }

            [Fact]
            public void Setea_la_propiedad_Verbo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogExcepcion.Verbo, this.Target.Verbo);
            }

            [Fact]
            public void Setea_la_propiedad_TraceIdentifier()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogExcepcion.TraceIdentifier, this.Target.TraceIdentifier);
            }

            [Fact]
            public void Setea_la_propiedad_UsuarioID()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogExcepcion.UsuarioID, this.Target.UsuarioID);
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
