using CareWell.Domain.Agenda;
using CareWell.Domain.DomainServices.Agenda;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Agenda;
using CareWell.Global.Enumeraciones.Agenda;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Agenda
{
    public class EventoAgendaTest : TestClassBase<EventoAgenda>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new EventoAgenda();
        }

        public class ElMetodo_Crear : EventoAgendaTest
        {
            private CrearEventoAgenda crearEventoAgenda;
            private Mock<IExpansorRecurrenciaDomainService> expansorRecurrenciaDomainService;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: DateTime.Now.AddDays(1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: new DefinirRecurrenciaEventoAgenda
                    (
                        FrecuenciaRecurrencia: FrecuenciaRecurrenciaEnum.Semanal,
                        Intervalo: 1,
                        FechaFin: DateTime.Now.AddDays(2)
                    ),
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                this.expansorRecurrenciaDomainService = new Mock<IExpansorRecurrenciaDomainService>();

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            }

            private void Action()
            {
                this.Target.Crear(this.crearEventoAgenda,
                                  this.expansorRecurrenciaDomainService.Object,
                                  this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Si_la_Persona_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearEventoAgenda = this.crearEventoAgenda with { Persona = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.PersonaNoExiste, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_el_Titulo_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearEventoAgenda = this.crearEventoAgenda with { Titulo = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.TituloEventoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_la_FechaHoraInicio_es_default_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearEventoAgenda = this.crearEventoAgenda with { FechaHoraInicio = default };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.FechaHoraInicioEventoRequerida, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_la_Duracion_es_menor_a_cero_o_igual_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearEventoAgenda = this.crearEventoAgenda with { Duracion = TimeSpan.Zero };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.DuracionEventoInvalida, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_el_Tipo_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearEventoAgenda = this.crearEventoAgenda with { Tipo = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.TipoEventoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_el_Tipo_no_es_agendable_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearEventoAgenda = this.crearEventoAgenda with { Tipo = Mock.Of<TipoEvento>() };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.TipoEventoNoEsAgendable, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_los_MinutosAnticipacionRecordatorio_son_menor_o_igual_a_cero_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearEventoAgenda = this.crearEventoAgenda with { MinutosAnticipacionRecordatorio = 0 };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.AnticipacionRecordatorioInvalida, excepcionEsperada.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeAdministrarAgenda_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeAdministrarAgenda(this.crearEventoAgenda.Persona, this.crearEventoAgenda.Creador), Times.Once);
            }

            [Fact]
            public void Setea_la_propiedad_Persona()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearEventoAgenda.Persona, this.Target.Persona);
            }

            [Fact]
            public void Setea_la_propiedad_Creador()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearEventoAgenda.Creador, this.Target.Creador);
            }

            [Fact]
            public void Setea_la_propiedad_Titulo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearEventoAgenda.Titulo, this.Target.Titulo);
            }

            [Fact]
            public void Setea_la_propiedad_Descripcion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearEventoAgenda.Descripcion, this.Target.Descripcion);
            }

            [Fact]
            public void Setea_la_propiedad_Tipo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearEventoAgenda.Tipo, this.Target.Tipo);
            }

            [Fact]
            public void Setea_la_propiedad_FechaHoraInicio()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearEventoAgenda.FechaHoraInicio, this.Target.FechaHoraInicio);
            }

            [Fact]
            public void Setea_la_propiedad_Duracion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearEventoAgenda.Duracion, this.Target.Duracion);
            }

            [Fact]
            public void Setea_la_propiedad_GeneraEventoSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearEventoAgenda.GenerarEventoSalud, this.Target.GenerarEventoSalud);
            }

            [Fact]
            public void Setea_la_propiedad_MinutosAnticipacionRecordatorio()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearEventoAgenda.MinutosAnticipacionRecordatorio, this.Target.MinutosAnticipacionRecordatorio);
            }

            [Fact]
            public void Si_existe_Recurrencia_llama_una_vez_al_metodo_ConstruirRegla_del_ExpansorRecurrenciaDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.expansorRecurrenciaDomainService.Verify(v => v.ConstruirRegla(this.crearEventoAgenda.Recurrencia!, this.crearEventoAgenda.FechaHoraInicio), Times.Once);
            }

            [Fact]
            public void Si_no_existe_Recurrencia_no_llama_nunca_al_metodo_ConstruirRegla_del_ExpansorRecurrenciaDomainService()
            {
                // Arrange
                this.crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: DateTime.Now.AddDays(1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: null,
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 1
                );

                // Action
                this.Action();

                // Assert
                this.expansorRecurrenciaDomainService.Verify(v => v.ConstruirRegla(It.IsAny<DefinirRecurrenciaEventoAgenda>(), It.IsAny<DateTime>()), Times.Never);
            }

            [Fact]
            public void Si_la_ReglaRecurrencia_generada_difiere_de_la_anterior_registrada_setea_la_propiedad_FechasExceptuadas_en_null()
            {
                // Arrange
                this.expansorRecurrenciaDomainService.Setup(s => s.ConstruirRegla(this.crearEventoAgenda.Recurrencia!, this.crearEventoAgenda.FechaHoraInicio)).Returns("Regla");
                this.Action();

                var fechaExceptuada = DateTime.Today.AddDays(1);
                var serializadorFechasExceptuadas = Mock.Of<ISerializadorFechasExceptuadasDomainService>(s =>
                    s.DeserializarFechasExceptuadas(It.IsAny<string>()) == new List<DateTime>() &&
                    s.SerializarFechasExceptuadas(It.IsAny<List<DateTime>>()) == fechaExceptuada.ToString()
                );
                this.Target.CancelarOcurrencia(fechaExceptuada,
                                               Mock.Of<Persona>(),
                                               serializadorFechasExceptuadas,
                                               this.validadorPermisoAccion.Object);

                this.expansorRecurrenciaDomainService.Setup(s => s.ConstruirRegla(this.crearEventoAgenda.Recurrencia!, this.crearEventoAgenda.FechaHoraInicio)).Returns("Regla2");


                // Action
                this.Action();

                // Assert
                Assert.Null(this.Target.FechasExceptuadas);
            }

            [Fact]
            public void Setea_la_propiedad_ReglaRecurrencia()
            {
                // Arrange
                var reglaRecurrenciaGenerada = "REGLA";
                this.expansorRecurrenciaDomainService.Setup(s => s.ConstruirRegla(this.crearEventoAgenda.Recurrencia!, this.crearEventoAgenda.FechaHoraInicio)).Returns(reglaRecurrenciaGenerada);

                // Action
                this.Action();

                // Assert
                Assert.Equal(reglaRecurrenciaGenerada, this.Target.ReglaRecurrencia);
            }
        }

        public class ElMetodo_Modificar : EventoAgendaTest
        {
            private ModificarEventoAgenda modificarEventoAgenda;
            private Mock<IExpansorRecurrenciaDomainService> expansorRecurrenciaDomainService;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.modificarEventoAgenda = new ModificarEventoAgenda
                (
                    Solicitante: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: DateTime.Now.AddDays(1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: new DefinirRecurrenciaEventoAgenda
                    (
                        FrecuenciaRecurrencia: FrecuenciaRecurrenciaEnum.Semanal,
                        Intervalo: 1,
                        FechaFin: DateTime.Now.AddDays(2)
                    ),
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                this.expansorRecurrenciaDomainService = new Mock<IExpansorRecurrenciaDomainService>();

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();

                #region Crear

                var crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: DateTime.Now.AddDays(1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: new DefinirRecurrenciaEventoAgenda
                    (
                        FrecuenciaRecurrencia: FrecuenciaRecurrenciaEnum.Semanal,
                        Intervalo: 1,
                        FechaFin: DateTime.Now.AddDays(2)
                    ),
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                this.Target.Crear(crearEventoAgenda,
                                  Mock.Of<IExpansorRecurrenciaDomainService>(),
                                  Mock.Of<IValidadorPermisoAccion>());

                #endregion
            }

            private void Action()
            {
                this.Target.Modificar(this.modificarEventoAgenda,
                                      this.expansorRecurrenciaDomainService.Object,
                                      this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Si_el_Titulo_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.modificarEventoAgenda = this.modificarEventoAgenda with { Titulo = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.TituloEventoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_la_FechaHoraInicio_es_default_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.modificarEventoAgenda = this.modificarEventoAgenda with { FechaHoraInicio = default };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.FechaHoraInicioEventoRequerida, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_la_Duracion_es_menor_a_cero_o_igual_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.modificarEventoAgenda = this.modificarEventoAgenda with { Duracion = TimeSpan.Zero };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.DuracionEventoInvalida, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_el_Tipo_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.modificarEventoAgenda = this.modificarEventoAgenda with { Tipo = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.TipoEventoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_el_Tipo_no_es_agendable_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.modificarEventoAgenda = this.modificarEventoAgenda with { Tipo = Mock.Of<TipoEvento>() };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.TipoEventoNoEsAgendable, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_los_MinutosAnticipacionRecordatorio_son_menor_o_igual_a_cero_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.modificarEventoAgenda = this.modificarEventoAgenda with { MinutosAnticipacionRecordatorio = 0 };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.AnticipacionRecordatorioInvalida, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_la_FechaHoraInicio_es_menor_o_igual_a_la_actual_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                var crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: DateTime.Now.AddDays(-1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: new DefinirRecurrenciaEventoAgenda
                    (
                        FrecuenciaRecurrencia: FrecuenciaRecurrenciaEnum.Semanal,
                        Intervalo: 1,
                        FechaFin: DateTime.Now.AddDays(2)
                    ),
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                this.Target.Crear(crearEventoAgenda,
                                  this.expansorRecurrenciaDomainService.Object,
                                  this.validadorPermisoAccion.Object);

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NoSePuedeModificarEventoYaIniciado, excepcionEsperada.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_PermiteAdministrarAgenda_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeAdministrarAgenda(this.Target.Persona, this.modificarEventoAgenda.Solicitante), Times.Once);
            }

            [Fact]
            public void Setea_la_propiedad_Titulo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarEventoAgenda.Titulo, this.Target.Titulo);
            }

            [Fact]
            public void Setea_la_propiedad_Descripcion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarEventoAgenda.Descripcion, this.Target.Descripcion);
            }

            [Fact]
            public void Setea_la_propiedad_Tipo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.modificarEventoAgenda.Tipo, this.Target.Tipo);
            }

            [Fact]
            public void Setea_la_propiedad_FechaHoraInicio()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarEventoAgenda.FechaHoraInicio, this.Target.FechaHoraInicio);
            }

            [Fact]
            public void Setea_la_propiedad_Duracion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarEventoAgenda.Duracion, this.Target.Duracion);
            }

            [Fact]
            public void Setea_la_propiedad_GeneraEventoSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarEventoAgenda.GenerarEventoSalud, this.Target.GenerarEventoSalud);
            }

            [Fact]
            public void Setea_la_propiedad_MinutosAnticipacionRecordatorio()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarEventoAgenda.MinutosAnticipacionRecordatorio, this.Target.MinutosAnticipacionRecordatorio);
            }

            [Fact]
            public void Si_existe_Recurrencia_llama_una_vez_al_metodo_ConstruirRegla_del_ExpansorRecurrenciaDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.expansorRecurrenciaDomainService.Verify(v => v.ConstruirRegla(this.modificarEventoAgenda.Recurrencia!, this.modificarEventoAgenda.FechaHoraInicio), Times.Once);
            }

            [Fact]
            public void Si_no_existe_Recurrencia_no_llama_nunca_al_metodo_ConstruirRegla_del_ExpansorRecurrenciaDomainService()
            {
                // Arrange
                this.modificarEventoAgenda = new ModificarEventoAgenda
                (
                    Solicitante: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: DateTime.Now.AddDays(1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: null,
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 1
                );

                // Action
                this.Action();

                // Assert
                this.expansorRecurrenciaDomainService.Verify(v => v.ConstruirRegla(It.IsAny<DefinirRecurrenciaEventoAgenda>(), It.IsAny<DateTime>()), Times.Never);
            }

            [Fact]
            public void Si_la_ReglaRecurrencia_generada_difiere_de_la_anterior_registrada_setea_la_propiedad_FechasExceptuadas_en_null()
            {
                // Arrange
                this.expansorRecurrenciaDomainService.Setup(s => s.ConstruirRegla(this.modificarEventoAgenda.Recurrencia!, this.modificarEventoAgenda.FechaHoraInicio)).Returns("Regla");
                this.Action();

                var fechaExceptuada = DateTime.Today.AddDays(1);
                var serializadorFechasExceptuadas = Mock.Of<ISerializadorFechasExceptuadasDomainService>(s =>
                    s.DeserializarFechasExceptuadas(It.IsAny<string>()) == new List<DateTime>() &&
                    s.SerializarFechasExceptuadas(It.IsAny<List<DateTime>>()) == fechaExceptuada.ToString()
                );
                this.Target.CancelarOcurrencia(fechaExceptuada,
                                               Mock.Of<Persona>(),
                                               serializadorFechasExceptuadas,
                                               this.validadorPermisoAccion.Object);

                this.expansorRecurrenciaDomainService.Setup(s => s.ConstruirRegla(this.modificarEventoAgenda.Recurrencia!, this.modificarEventoAgenda.FechaHoraInicio)).Returns("Regla2");

                // Action
                this.Action();

                // Assert
                Assert.Null(this.Target.FechasExceptuadas);
            }

            [Fact]
            public void Setea_la_propiedad_ReglaRecurrencia()
            {
                // Arrange
                var reglaRecurrenciaGenerada = "REGLA";
                this.expansorRecurrenciaDomainService.Setup(s => s.ConstruirRegla(this.modificarEventoAgenda.Recurrencia!, this.modificarEventoAgenda.FechaHoraInicio)).Returns(reglaRecurrenciaGenerada);

                // Action
                this.Action();

                // Assert
                Assert.Equal(reglaRecurrenciaGenerada, this.Target.ReglaRecurrencia);
            }
        }

        public class ElMetodo_CancelarOcurrencia : EventoAgendaTest
        {
            private DateTime fechaOcurrencia;
            private Persona solicitante;
            private Mock<ISerializadorFechasExceptuadasDomainService> serializadorFechasExceptuadasDomainService;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.fechaOcurrencia = DateTime.Now.AddDays(1);
                this.solicitante = Mock.Of<Persona>();

                this.serializadorFechasExceptuadasDomainService = new Mock<ISerializadorFechasExceptuadasDomainService>();
                this.serializadorFechasExceptuadasDomainService.Setup(v => v.DeserializarFechasExceptuadas(this.Target.FechasExceptuadas)).Returns(new List<DateTime>());

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();

                #region Crear

                var crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: DateTime.Now.AddDays(1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: new DefinirRecurrenciaEventoAgenda
                    (
                        FrecuenciaRecurrencia: FrecuenciaRecurrenciaEnum.Semanal,
                        Intervalo: 1,
                        FechaFin: DateTime.Now.AddDays(2)
                    ),
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                var expansorRecurrenciaDomainService = Mock.Of<IExpansorRecurrenciaDomainService>(e => e.ConstruirRegla(It.IsAny<DefinirRecurrenciaEventoAgenda>(), It.IsAny<DateTime>()) == "REGLA");
                var validadorPermisoAccion = Mock.Of<IValidadorPermisoAccion>();

                this.Target.Crear(crearEventoAgenda,
                                  expansorRecurrenciaDomainService,
                                  validadorPermisoAccion);

                #endregion
            }

            private void Action()
            {
                this.Target.CancelarOcurrencia(this.fechaOcurrencia,
                                               this.solicitante,
                                               this.serializadorFechasExceptuadasDomainService.Object,
                                               this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_PermiteAdministrarAgenda_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeAdministrarAgenda(this.Target.Persona, this.solicitante), Times.Once);
            }

            [Fact]
            public void Si_la_ReglaRecurrencia_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.Target = new EventoAgenda();

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ElEventoNoEsRecurrente, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_la_FechaOcurrencia_es_menor_a_la_actual_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.fechaOcurrencia = DateTime.Now.AddMinutes(-1);

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NoSePuedeCancelarOcurrenciaPasada, excepcionEsperada.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_DeserializarFechasExceptuadas_del_SerializadorFechasExceptuadasDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.serializadorFechasExceptuadasDomainService.Verify(v => v.DeserializarFechasExceptuadas(this.Target.FechasExceptuadas), Times.Once);
            }

            [Fact]
            public void Si_la_FechaOcurrencia_seleccionada_no_estaba_exceptuada_la_agrega_y_llama_una_vez_al_metodo_SerializarFechasExceptuadas_del_SerializadorFechasExceptuadasDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.serializadorFechasExceptuadasDomainService.Verify(v => v.SerializarFechasExceptuadas(It.Is<List<DateTime>>(f => f.Contains(this.fechaOcurrencia))), Times.Once);
            }

            [Fact]
            public void Setea_la_propiedad_FechasExceptuadas()
            {
                // Arrange
                this.serializadorFechasExceptuadasDomainService.Setup(v => v.SerializarFechasExceptuadas(It.IsAny<List<DateTime>>())).Returns(this.fechaOcurrencia.ToString());

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.fechaOcurrencia.ToString(), this.Target.FechasExceptuadas);
            }
        }

        public class ElMetodo_ActualizarUltimaGeneracionEventoSalud : EventoAgendaTest
        {
            private DateTime fechaUltimaGeneracionEventoSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.fechaUltimaGeneracionEventoSalud = DateTime.Now;
            }

            private void Action()
            {
                this.Target.ActualizarUltimaGeneracionEventoSalud(this.fechaUltimaGeneracionEventoSalud);
            }

            [Fact]
            public void Si_la_FechaUltimaGeneracionEventoSalud_no_tiene_valor_la_setea_con_el_enviado_por_parametro()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.fechaUltimaGeneracionEventoSalud, this.Target.FechaUltimaGeneracionEventoSalud);
            }

            [Fact]
            public void Si_la_FechaUltimaGeneracionEventoSalud_tiene_valor_y_es_menor_a_la_enviada_la_setea_con_el_enviado_por_parametro()
            {
                // Arrange
                this.Target.ActualizarUltimaGeneracionEventoSalud(this.fechaUltimaGeneracionEventoSalud.AddDays(-1));

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.fechaUltimaGeneracionEventoSalud, this.Target.FechaUltimaGeneracionEventoSalud);
            }

            [Fact]
            public void Si_la_FechaUltimaGeneracionEventoSalud_tiene_valor_y_no_es_menor_a_la_enviada_no_la_modifica()
            {
                // Arrange
                var fechaUltimaGeneracionMayor = this.fechaUltimaGeneracionEventoSalud.AddDays(1);
                this.Target.ActualizarUltimaGeneracionEventoSalud(fechaUltimaGeneracionMayor);

                // Action
                this.Action();

                // Assert
                Assert.Equal(fechaUltimaGeneracionMayor, this.Target.FechaUltimaGeneracionEventoSalud);
            }
        }

        public class ElMetodo_Eliminar : EventoAgendaTest
        {
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
            private Persona solicitante;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();

                this.solicitante = Mock.Of<Persona>();

                #region Crear

                var crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: DateTime.Now.AddDays(1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: new DefinirRecurrenciaEventoAgenda
                    (
                        FrecuenciaRecurrencia: FrecuenciaRecurrenciaEnum.Semanal,
                        Intervalo: 1,
                        FechaFin: DateTime.Now.AddDays(2)
                    ),
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                var expansorRecurrenciaDomainService = Mock.Of<IExpansorRecurrenciaDomainService>(e => e.ConstruirRegla(It.IsAny<DefinirRecurrenciaEventoAgenda>(), It.IsAny<DateTime>()) == "REGLA");
                var validadorPermisoAccion = Mock.Of<IValidadorPermisoAccion>();

                this.Target.Crear(crearEventoAgenda,
                                  expansorRecurrenciaDomainService,
                                  validadorPermisoAccion);

                #endregion
            }

            private void Action()
            {
                this.Target.Eliminar(this.validadorPermisoAccion.Object,
                                     this.solicitante);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_PermiteAdministrarAgenda_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeAdministrarAgenda(this.Target.Persona, this.solicitante), Times.Once);
            }

            [Fact]
            public void Si_la_FechaHoraInicio_es_menor_a_la_actual_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                var crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: DateTime.Now.AddMinutes(-1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: new DefinirRecurrenciaEventoAgenda
                    (
                        FrecuenciaRecurrencia: FrecuenciaRecurrenciaEnum.Semanal,
                        Intervalo: 1,
                        FechaFin: DateTime.Now.AddDays(2)
                    ),
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                var expansorRecurrenciaDomainService = Mock.Of<IExpansorRecurrenciaDomainService>(e => e.ConstruirRegla(It.IsAny<DefinirRecurrenciaEventoAgenda>(), It.IsAny<DateTime>()) == "REGLA");
                var validadorPermisoAccion = Mock.Of<IValidadorPermisoAccion>();

                this.Target.Crear(crearEventoAgenda,
                                  expansorRecurrenciaDomainService,
                                  validadorPermisoAccion);

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NoSePuedeEliminarEventoYaIniciado, excepcionEsperada.Message);
            }
        }

        public class ElMetodo_ObtenerOcurrencias : EventoAgendaTest
        {
            private Mock<IExpansorRecurrenciaDomainService> expansorRecurrenciaDomainService;
            private DateTime fechaHoraActual;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.expansorRecurrenciaDomainService = new Mock<IExpansorRecurrenciaDomainService>();
                this.expansorRecurrenciaDomainService.Setup(s => s.ExpandirOcurrencias(It.IsAny<string>(), It.IsAny<DateTime>(), It.IsAny<string?>(), It.IsAny<DateTime>(), It.IsAny<DateTime>())).Returns(new List<DateTime>());

                this.fechaHoraActual = DateTime.Now;

                #region Crear

                var crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: DateTime.Now.AddDays(1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: new DefinirRecurrenciaEventoAgenda
                    (
                        FrecuenciaRecurrencia: FrecuenciaRecurrenciaEnum.Semanal,
                        Intervalo: 1,
                        FechaFin: DateTime.Now.AddDays(2)
                    ),
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                var expansorRecurrenciaDomainService = Mock.Of<IExpansorRecurrenciaDomainService>(e => e.ConstruirRegla(It.IsAny<DefinirRecurrenciaEventoAgenda>(), It.IsAny<DateTime>()) == "REGLA");
                var validadorPermisoAccion = Mock.Of<IValidadorPermisoAccion>();

                this.Target.Crear(crearEventoAgenda,
                                  expansorRecurrenciaDomainService,
                                  validadorPermisoAccion);

                #endregion
            }

            private List<DateTime> Action()
            {
                return this.Target.ObtenerOcurrencias(this.expansorRecurrenciaDomainService.Object,
                                                      this.fechaHoraActual);
            }

            [Fact]
            public void Si_la_FechaUltimaGeneracionEventoSalud_y_la_regla_de_recurrencia_no_son_null_llama_una_vez_al_metodo_ExpandirOcurrencias_del_ExpansorRecurrenciaDomainService_con_esta_fecha()
            {
                // Arrange
                var fechaHoraEsperada = DateTime.Now;
                this.Target.ActualizarUltimaGeneracionEventoSalud(fechaHoraEsperada);

                // Action
                this.Action();

                // Assert
                this.expansorRecurrenciaDomainService.Verify(v => v.ExpandirOcurrencias(this.Target.ReglaRecurrencia!,
                                                                                        this.Target.FechaHoraInicio,
                                                                                        this.Target.FechasExceptuadas,
                                                                                        fechaHoraEsperada,
                                                                                        this.fechaHoraActual), Times.Once);
            }

            [Fact]
            public void Si_la_FechaUltimaGeneracionEventoSalud_es_null_y_la_regla_de_recurrencia_no_es_null_llama_una_vez_al_metodo_ExpandirOcurrencias_del_ExpansorRecurrenciaDomainService_con_la_FechaHoraInicio()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.expansorRecurrenciaDomainService.Verify(v => v.ExpandirOcurrencias(this.Target.ReglaRecurrencia!,
                                                                                        this.Target.FechaHoraInicio,
                                                                                        this.Target.FechasExceptuadas,
                                                                                        this.Target.FechaHoraInicio,
                                                                                        this.fechaHoraActual), Times.Once);
            }

            [Fact]
            public void Si_la_regla_de_recurrencia_no_es_null_retorna_la_lista_de_fechas_devuelta_por_el_servicio_expansor_de_ocurrencias()
            {
                // Arrange
                var listafechas = new List<DateTime> { DateTime.Now, DateTime.Now.AddDays(1) };
                this.expansorRecurrenciaDomainService.Setup(s => s.ExpandirOcurrencias(It.IsAny<string>(), It.IsAny<DateTime>(), It.IsAny<string?>(), It.IsAny<DateTime>(), It.IsAny<DateTime>())).Returns(listafechas);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equivalent(listafechas, resultado);
            }

            [Fact]
            public void Si_la_regla_de_recurrencia_es_null_y_la_FechaHoraInicio_es_mayor_o_igual_a_la_cota_ultima_generacion_de_evento_y_menor_a_la_enviada_por_parametro_retorna_la_lista_de_fechas_con_esta()
            {
                // Arrange
                this.Target = new EventoAgenda();

                #region Crear

                var crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: this.fechaHoraActual.AddMinutes(-1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: null,
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                var expansorRecurrenciaDomainService = Mock.Of<IExpansorRecurrenciaDomainService>(e => e.ConstruirRegla(It.IsAny<DefinirRecurrenciaEventoAgenda>(), It.IsAny<DateTime>()) == "REGLA");
                var validadorPermisoAccion = Mock.Of<IValidadorPermisoAccion>();

                this.Target.Crear(crearEventoAgenda,
                                  expansorRecurrenciaDomainService,
                                  validadorPermisoAccion);

                #endregion

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equivalent(new List<DateTime> { this.Target.FechaHoraInicio }, resultado);
            }

            [Fact]
            public void Si_la_regla_de_recurrencia_es_null_y_la_FechaHoraInicio_es_menor_a_la_enviada_por_parametro_retorna_la_lista_de_fechas_vacia()
            {
                // Arrange
                this.Target = new EventoAgenda();

                #region Crear

                var crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: this.fechaHoraActual.AddMinutes(1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: null,
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                var expansorRecurrenciaDomainService = Mock.Of<IExpansorRecurrenciaDomainService>(e => e.ConstruirRegla(It.IsAny<DefinirRecurrenciaEventoAgenda>(), It.IsAny<DateTime>()) == "REGLA");
                var validadorPermisoAccion = Mock.Of<IValidadorPermisoAccion>();

                this.Target.Crear(crearEventoAgenda,
                                  expansorRecurrenciaDomainService,
                                  validadorPermisoAccion);

                #endregion

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Empty(resultado);
            }

            [Fact]
            public void Retorna_siempre_una_instancia_del_tipo_List_DateTime()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<List<DateTime>>(resultado);
            }
        }

        public class ElMetodo_ObtenerOcurrenciasEnRango : EventoAgendaTest
        {
            private Mock<IExpansorRecurrenciaDomainService> expansorRecurrenciaDomainService;
            private DateTime fechaHoraDesde;
            private DateTime fechaHoraHasta;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.expansorRecurrenciaDomainService = new Mock<IExpansorRecurrenciaDomainService>();
                this.expansorRecurrenciaDomainService.Setup(s => s.ExpandirOcurrencias(It.IsAny<string>(), It.IsAny<DateTime>(), It.IsAny<string?>(), It.IsAny<DateTime>(), It.IsAny<DateTime>())).Returns(new List<DateTime>());

                this.fechaHoraDesde = DateTime.Now.AddMinutes(-10);
                this.fechaHoraHasta = DateTime.Now;

                #region Crear

                var crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: DateTime.Now.AddDays(1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: new DefinirRecurrenciaEventoAgenda
                    (
                        FrecuenciaRecurrencia: FrecuenciaRecurrenciaEnum.Semanal,
                        Intervalo: 1,
                        FechaFin: DateTime.Now.AddDays(2)
                    ),
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                var expansorRecurrenciaDomainService = Mock.Of<IExpansorRecurrenciaDomainService>(e => e.ConstruirRegla(It.IsAny<DefinirRecurrenciaEventoAgenda>(), It.IsAny<DateTime>()) == "REGLA");
                var validadorPermisoAccion = Mock.Of<IValidadorPermisoAccion>();

                this.Target.Crear(crearEventoAgenda,
                                  expansorRecurrenciaDomainService,
                                  validadorPermisoAccion);

                #endregion
            }

            private List<DateTime> Action()
            {
                return this.Target.ObtenerOcurrenciasEnRango(this.expansorRecurrenciaDomainService.Object,
                                                             this.fechaHoraDesde,
                                                             this.fechaHoraHasta);
            }

            [Fact]
            public void Si_la_regla_de_recurrencia_no_es_null_llama_una_vez_al_metodo_ExpandirOcurrencias_del_ExpansorRecurrenciaDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.expansorRecurrenciaDomainService.Verify(v => v.ExpandirOcurrencias(this.Target.ReglaRecurrencia!,
                                                                                        this.Target.FechaHoraInicio,
                                                                                        this.Target.FechasExceptuadas,
                                                                                        this.fechaHoraDesde,
                                                                                        this.fechaHoraHasta), Times.Once);
            }

            [Fact]
            public void Si_la_regla_de_recurrencia_no_es_null_retorna_la_lista_de_fechas_devuelta_por_el_servicio_expansor_de_ocurrencias()
            {
                // Arrange
                var listafechas = new List<DateTime> { DateTime.Now, DateTime.Now.AddDays(1) };
                this.expansorRecurrenciaDomainService.Setup(s => s.ExpandirOcurrencias(It.IsAny<string>(), It.IsAny<DateTime>(), It.IsAny<string?>(), It.IsAny<DateTime>(), It.IsAny<DateTime>())).Returns(listafechas);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equivalent(listafechas, resultado);
            }

            [Fact]
            public void Si_la_regla_de_recurrencia_es_null_y_la_FechaHoraInicio_es_mayor_o_igual_a_FechaHoraHasta_y_menor_a_la_FechaHoraDesde_retorna_la_lista_de_fechas_con_esta()
            {
                // Arrange
                this.Target = new EventoAgenda();

                #region Crear

                var crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: this.fechaHoraHasta.AddMinutes(-1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: null,
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                var expansorRecurrenciaDomainService = Mock.Of<IExpansorRecurrenciaDomainService>(e => e.ConstruirRegla(It.IsAny<DefinirRecurrenciaEventoAgenda>(), It.IsAny<DateTime>()) == "REGLA");
                var validadorPermisoAccion = Mock.Of<IValidadorPermisoAccion>();

                this.Target.Crear(crearEventoAgenda,
                                  expansorRecurrenciaDomainService,
                                  validadorPermisoAccion);

                #endregion

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equivalent(new List<DateTime> { this.Target.FechaHoraInicio }, resultado);
            }

            [Fact]
            public void Si_la_regla_de_recurrencia_es_null_y_la_FechaHoraInicio_es_menor_a_la_FechaHoraDesde_retorna_la_lista_de_fechas_vacia()
            {
                // Arrange
                this.Target = new EventoAgenda();

                #region Crear

                var crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: this.fechaHoraDesde.AddMinutes(-1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: null,
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                var expansorRecurrenciaDomainService = Mock.Of<IExpansorRecurrenciaDomainService>(e => e.ConstruirRegla(It.IsAny<DefinirRecurrenciaEventoAgenda>(), It.IsAny<DateTime>()) == "REGLA");
                var validadorPermisoAccion = Mock.Of<IValidadorPermisoAccion>();

                this.Target.Crear(crearEventoAgenda,
                                  expansorRecurrenciaDomainService,
                                  validadorPermisoAccion);

                #endregion

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Empty(resultado);
            }

            [Fact]
            public void Si_la_regla_de_recurrencia_es_null_y_la_FechaHoraInicio_es_mayor_a_la_FechaHoraHasta_retorna_la_lista_de_fechas_vacia()
            {
                // Arrange
                this.Target = new EventoAgenda();

                #region Crear

                var crearEventoAgenda = new CrearEventoAgenda
                (
                    Persona: Mock.Of<Persona>(),
                    Creador: Mock.Of<Persona>(),
                    Titulo: "Titulo de prueba",
                    Descripcion: "Descripcion de prueba",
                    Tipo: Mock.Of<TipoEvento>(t => t.Agendable == true),
                    FechaHoraInicio: this.fechaHoraHasta.AddMinutes(1),
                    Duracion: TimeSpan.FromHours(1),
                    Recurrencia: null,
                    GenerarEventoSalud: true,
                    MinutosAnticipacionRecordatorio: 15
                );

                var expansorRecurrenciaDomainService = Mock.Of<IExpansorRecurrenciaDomainService>(e => e.ConstruirRegla(It.IsAny<DefinirRecurrenciaEventoAgenda>(), It.IsAny<DateTime>()) == "REGLA");
                var validadorPermisoAccion = Mock.Of<IValidadorPermisoAccion>();

                this.Target.Crear(crearEventoAgenda,
                                  expansorRecurrenciaDomainService,
                                  validadorPermisoAccion);

                #endregion

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Empty(resultado);
            }

            [Fact]
            public void Retorna_siempre_una_instancia_del_tipo_List_DateTime()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<List<DateTime>>(resultado);
            }
        }
    }
}
