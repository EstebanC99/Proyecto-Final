using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Salud
{
    public class NotaEventoSaludTest : TestClassBase<NotaEventoSalud>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new NotaEventoSalud();
        }

        public class ElMetodo_Crear : NotaEventoSaludTest
        {
            private CrearNotaEventoSalud crearNotaEvento;
            private Mock<EventoSalud> eventoSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.crearNotaEvento = new CrearNotaEventoSalud(
                    Autor: Mock.Of<Persona>(),
                    Contenido: "Contenido de Nota"
                );

                this.eventoSalud = new Mock<EventoSalud>();
            }

            private void Action()
            {
                this.Target.Crear(this.crearNotaEvento,
                                  this.eventoSalud.Object);
            }

            [Fact]
            public void Si_el_Autor_es_null_arroja_un_ValidationException_con_mensaje_informativo()
            {
                // Arrange
                this.crearNotaEvento = this.crearNotaEvento with { Autor = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.AutorRequeridoParaNotaDeSalud, exception.Message);
            }

            [Fact]
            public void Si_el_Contenido_es_null_arroja_un_ValidationException_con_mensaje_informativo()
            {
                // Arrange
                this.crearNotaEvento = this.crearNotaEvento with { Contenido = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ContenidoRequeridoParaNotaDeSalud, exception.Message);
            }

            [Fact]
            public void Setea_la_propiedad_Autor()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearNotaEvento.Autor, this.Target.Autor);
            }

            [Fact]
            public void Setea_la_propiedad_FechaHora_con_la_actual()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(DateTime.Now.Date, this.Target.FechaHora.Date);
            }

            [Fact]
            public void Setea_la_propiedad_Contenido()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearNotaEvento.Contenido, this.Target.Contenido);
            }

            [Fact]
            public void Setea_la_propiedad_EventoSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.eventoSalud.Object, this.Target.EventoSalud);
            }
        }

        public class ElMetodo_ModificarContenido : NotaEventoSaludTest
        {
            private string contenido;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.contenido = "Contenido de nota";
            }

            private void Action()
            {
                this.Target.ModificarContenido(this.contenido);
            }

            [Fact]
            public void Si_el_Contenido_es_null_arroja_un_ValidationException_con_mensaje_informativo()
            {
                // Arrange
                this.contenido = null;

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ContenidoRequeridoParaNotaDeSalud, exception.Message);
            }

            [Fact]
            public void Setea_la_propiedad_Contenido()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.contenido, this.Target.Contenido);
            }
        }
    }
}
