using CareWell.Domain.Agenda;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Salud
{
    public class EventoSaludTest : TestClassBase<EventoSalud>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new EventoSalud();
        }

        public class ElMetodo_GenerarDesdeAgenda : EventoSaludTest
        {
            private EventoAgenda eventoAgenda;
            private DateTime fechaOcurrencia;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.eventoAgenda = Mock.Of<EventoAgenda>(e =>
                    e.Persona == Mock.Of<Persona>() &&
                    e.Tipo == Mock.Of<TipoEvento>() &&
                    e.Titulo == "Titulo del evento" &&
                    e.GenerarEventoSalud == true
                );

                this.fechaOcurrencia = DateTime.Now;
            }

            private void Action()
            {
                this.Target.GenerarDesdeAgenda(this.eventoAgenda,
                                               this.fechaOcurrencia);
            }

            [Fact]
            public void Si_el_EventoAgenda_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.eventoAgenda = null;

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ElEventoAgendaEsRequeridoParaElEventoSalud, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_el_EventoAgenda_no_GeneraEventoSalud_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                Mock.Get(this.eventoAgenda).Setup(s => s.GenerarEventoSalud).Returns(false);

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ElEventoAgendaNoGeneraEventoSalud, excepcionEsperada.Message);
            }

            [Fact]
            public void Setea_la_propiedad_Persona()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.eventoAgenda.Persona, this.Target.Persona);
            }

            [Fact]
            public void Setea_la_propiedad_Tipo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.eventoAgenda.Tipo, this.Target.Tipo);
            }

            [Fact]
            public void Setea_la_propiedad_FechaHora()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.fechaOcurrencia, this.Target.FechaHora);
            }

            [Fact]
            public void Setea_la_propiedad_Descripcion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.eventoAgenda.Titulo, this.Target.Descripcion);
            }

            [Fact]
            public void Setea_la_propiedad_EventoAgenda()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.eventoAgenda, this.Target.EventoAgenda);
            }

            [Fact]
            public void Setea_la_propiedad_FechaOcurrenciaEventoAgenda()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.fechaOcurrencia, this.Target.FechaOcurrenciaEventoAgenda);
            }
        }
    }
}
