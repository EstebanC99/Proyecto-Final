using CareWell.Domain.Agenda;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
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

        public class ElMetodo_Crear : EventoSaludTest
        {
            private CrearEventoSalud crearEventoSalud;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.crearEventoSalud = new CrearEventoSalud(
                    Persona: Mock.Of<Persona>(),
                    Colaborador: Mock.Of<Persona>(),
                    Tipo: Mock.Of<TipoEvento>(),
                    FechaHora: DateTime.Now,
                    Descripcion: "Evento de Salud X"
                );

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            }

            private void Action()
            {
                this.Target.Crear(this.crearEventoSalud,
                                  this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeAdministrarEventosSalud_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeAdministrarEventosSalud(this.crearEventoSalud.Persona, this.crearEventoSalud.Colaborador), Times.Once);
            }

            [Fact]
            public void Si_la_Persona_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearEventoSalud = this.crearEventoSalud with { Persona = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.PersonaNoExiste, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_la_Tipo_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearEventoSalud = this.crearEventoSalud with { Tipo = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.TipoEventoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_la_FechaHora_es_valor_por_defecto_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearEventoSalud = this.crearEventoSalud with { FechaHora = default };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.FechaHoraInicioEventoRequerida, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_la_Descripcion_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearEventoSalud = this.crearEventoSalud with { Descripcion = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.LaDescripcionEsRequerida, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_la_FechaHora_es_a_futuro_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearEventoSalud = this.crearEventoSalud with { FechaHora = DateTime.Now.AddMinutes(1) };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.EventoSaludNoPuedeSerFuturoUtlizarAgenda, excepcionEsperada.Message);
            }

            [Fact]
            public void Setea_la_propiedad_Persona()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearEventoSalud.Persona, this.Target.Persona);
            }

            [Fact]
            public void Setea_la_propiedad_Tipo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearEventoSalud.Tipo, this.Target.Tipo);
            }

            [Fact]
            public void Setea_la_propiedad_FechaHora()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearEventoSalud.FechaHora, this.Target.FechaHora);
            }

            [Fact]
            public void Setea_la_propiedad_Descripcion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearEventoSalud.Descripcion, this.Target.Descripcion);
            }
        }

        public class ElMetodo_Eliminar : EventoSaludTest
        {
            private Persona colaborador;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.colaborador = Mock.Of<Persona>();

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            }

            private void Action()
            {
                this.Target.Eliminar(this.colaborador,
                                     this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeAdministrarEventosSalud_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeAdministrarEventosSalud(this.Target.Persona, this.colaborador), Times.Once);
            }

            [Fact]
            public void Vacia_la_lista_de_Notas()
            {
                // Arrange
                this.Target.Notas.Add(Mock.Of<NotaEventoSalud>());

                // Action
                this.Action();

                // Assert
                Assert.Empty(this.Target.Notas);
            }
        }

        public class ElMetodo_AgregarNota : EventoSaludTest
        {
            private CrearNotaEventoSalud crearNotaEventoSalud;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
            private Mock<IBaseFactory> baseFactory;
            private Mock<NotaEventoSalud> notaEventoSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.crearNotaEventoSalud = new CrearNotaEventoSalud(
                    Autor: Mock.Of<Persona>(),
                    Contenido: "Contenido"
                );

                this.notaEventoSalud = new Mock<NotaEventoSalud>();

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();

                this.baseFactory = new Mock<IBaseFactory>();
                this.baseFactory.Setup(s => s.Crear<NotaEventoSalud>()).Returns(this.notaEventoSalud.Object);
            }

            private void Action()
            {
                this.Target.AgregarNota(this.crearNotaEventoSalud,
                                        this.validadorPermisoAccion.Object,
                                        this.baseFactory.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeAdministrarEventosSalud_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeAdministrarEventosSalud(this.Target.Persona, this.crearNotaEventoSalud.Autor), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<NotaEventoSalud>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_del_NotaEventoSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.notaEventoSalud.Verify(v => v.Crear(this.crearNotaEventoSalud,
                                                         this.Target), Times.Once);
            }

            [Fact]
            public void Agrega_la_nota_a_la_lista_de_notas()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Contains(this.notaEventoSalud.Object, this.Target.Notas);
            }
        }

        public class ElMetodo_ModificarNota : EventoSaludTest
        {
            private ModificarNotaEventoSalud modificarNotaEventoSalud;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
            private Mock<NotaEventoSalud> notaEventoSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.modificarNotaEventoSalud = new ModificarNotaEventoSalud(
                    Colaborador: Mock.Of<Persona>(),
                    NotaID: 1,
                    Contenido: "Contenido"
                );

                this.notaEventoSalud = new Mock<NotaEventoSalud>();
                this.notaEventoSalud.Setup(s => s.ID).Returns(1);

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();

                this.Target.Notas.Add(this.notaEventoSalud.Object);
            }

            private void Action()
            {
                this.Target.ModificarNota(this.modificarNotaEventoSalud,
                                          this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeAdministrarEventosSalud_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeAdministrarEventosSalud(this.Target.Persona, this.modificarNotaEventoSalud.Colaborador), Times.Once);
            }

            [Fact]
            public void Si_no_encuenta_la_Nota_en_la_lista_de_Notas_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.Target.Notas.Clear();

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NotaNoEncontrada, exception.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ModificarContenido_del_NotaEventoSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.notaEventoSalud.Verify(v => v.ModificarContenido(this.modificarNotaEventoSalud.Contenido), Times.Once);
            }
        }

        public class ElMetodo_EliminarNota : EventoSaludTest
        {
            private EliminarNotaEventoSalud eliminarNotaEventoSalud;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
            private Mock<NotaEventoSalud> notaEventoSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.eliminarNotaEventoSalud = new EliminarNotaEventoSalud(
                    Colaborador: Mock.Of<Persona>(),
                    NotaID: 1
                );

                this.notaEventoSalud = new Mock<NotaEventoSalud>();
                this.notaEventoSalud.Setup(s => s.ID).Returns(1);

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();

                this.Target.Notas.Add(this.notaEventoSalud.Object);
            }

            private void Action()
            {
                this.Target.EliminarNota(this.eliminarNotaEventoSalud,
                                         this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeAdministrarEventosSalud_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeAdministrarEventosSalud(this.Target.Persona, this.eliminarNotaEventoSalud.Colaborador), Times.Once);
            }

            [Fact]
            public void Si_no_encuenta_la_Nota_en_la_lista_de_Notas_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.Target.Notas.Clear();

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NotaNoEncontrada, exception.Message);
            }

            [Fact]
            public void Elimina_la_nota_de_la_lista_de_Notas()
            {
                // Arrange
                this.notaEventoSalud.CallBase = true;

                // Action
                this.Action();

                // Assert
                Assert.DoesNotContain(this.notaEventoSalud.Object, this.Target.Notas);
            }
        }
    }
}
