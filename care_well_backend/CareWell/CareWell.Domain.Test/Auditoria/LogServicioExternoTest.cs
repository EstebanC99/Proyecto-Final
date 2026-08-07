using CareWell.Domain.Auditoria;
using CareWell.Domain.ValueObjects.Auditoria;
using CareWell.Global.Constantes.Auditoria;
using CareWell.Global.Extensions;

namespace CareWell.Domain.Test.Auditoria
{
    public class LogServicioExternoTest : TestClassBase<LogServicioExterno>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new LogServicioExterno();
        }

        public class ElMetodo_Registrar : LogServicioExternoTest
        {
            private RegistrarLogServicioExterno registrarLogServicioExterno;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.registrarLogServicioExterno = new RegistrarLogServicioExterno
                (
                    NombreServicioExterno: "Gemini",
                    Request: "Request X",
                    Response: "Response X"
                );
            }

            private void Action()
            {
                this.Target.Registrar(this.registrarLogServicioExterno);
            }

            [Fact]
            public void Setea_la_propiedad_NombreServicioExterno()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogServicioExterno.NombreServicioExterno, this.Target.NombreServicioExterno);
            }

            [Fact]
            public void Si_el_nombre_es_mayor_a_la_LongitudMaximaNombreServicioExterno_establecida_la_trunca()
            {
                // Arrange
                var nombreLargo = "Nombre para exceder el largo";

                for (int i = 1; i <= ParametrosLogServicioExterno.LongitudMaximaNombreServicioExterno; i++)
                {
                    nombreLargo += "A";
                }

                this.registrarLogServicioExterno = this.registrarLogServicioExterno with { NombreServicioExterno = nombreLargo };

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogServicioExterno.NombreServicioExterno.Truncate(ParametrosLogServicioExterno.LongitudMaximaNombreServicioExterno), this.Target.NombreServicioExterno);
            }

            [Fact]
            public void Setea_la_propiedad_Request()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogServicioExterno.Request, this.Target.Request);
            }

            [Fact]
            public void Setea_la_propiedad_Response()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarLogServicioExterno.Response, this.Target.Response);
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
