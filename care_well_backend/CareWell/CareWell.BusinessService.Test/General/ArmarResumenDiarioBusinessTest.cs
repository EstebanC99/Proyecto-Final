using CareWell.BusinessService.General;
using CareWell.DataViews.General;
using CareWell.DocumentIntelligence.ResumidorDiario;
using CareWell.Domain.Agenda;
using CareWell.Domain.DomainServices.Agenda;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Repository.Agenda;
using CareWell.Repository.Salud;
using Moq;

namespace CareWell.BusinessService.Test.General
{
    public class ArmarResumenDiarioBusinessTest : BusinessTestClassBase<ArmarResumenDiarioBusinessService>
    {
        private Mock<IEventoAgendaRepository> eventoAgendaRepository;
        private Mock<IEventoSaludRepository> eventoSaludRepository;
        private Mock<IHabitoVidaRepository> habitoVidaRepository;
        private Mock<IPersonaEstadoAnimoRepository> personaEstadoAnimoRepository;
        private Mock<IExpansorRecurrenciaDomainService> expansorRecurrenciaDomainService;
        private Mock<IResumidorDiarioAgent> resumidorDiarioAgent;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.eventoAgendaRepository = new Mock<IEventoAgendaRepository>();
            this.eventoSaludRepository = new Mock<IEventoSaludRepository>();
            this.habitoVidaRepository = new Mock<IHabitoVidaRepository>();
            this.personaEstadoAnimoRepository = new Mock<IPersonaEstadoAnimoRepository>();
            this.expansorRecurrenciaDomainService = new Mock<IExpansorRecurrenciaDomainService>();
            this.resumidorDiarioAgent = new Mock<IResumidorDiarioAgent>();

            this.Target = new ArmarResumenDiarioBusinessService(
                this.eventoAgendaRepository.Object,
                this.eventoSaludRepository.Object,
                this.habitoVidaRepository.Object,
                this.personaEstadoAnimoRepository.Object,
                this.expansorRecurrenciaDomainService.Object,
                this.resumidorDiarioAgent.Object
            );
        }

        public class ElMetodo_Armar : ArmarResumenDiarioBusinessTest
        {
            private ResumidorDiarioAgentResponse resumenGenerado;

            private int personaCuidadaID;
            private string personaCuidadaNombre;

            private Mock<EventoAgenda> eventoAgenda;
            private DateTime fechaOcurrenciaAgenda;

            private Mock<EventoSalud> eventoSaludPasado;

            private Mock<HabitoVida> habitoVidaCumplido;

            private Mock<PersonaEstadoAnimo> estadoAnimoAnterior;
            private Mock<PersonaEstadoAnimo> estadoAnimoPosterior;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.resumenGenerado = Mock.Of<ResumidorDiarioAgentResponse>(r =>
                    r.Habitos == new List<ResumidorDiarioAgentResponseHabito>() &&
                    r.EventosSalud == new List<ResumidorDiarioAgentResponseEventoSalud>() &&
                    r.Recomendaciones == new List<string>() &&
                    r.RecordatoriosHoy == new List<string>() &&
                    r.RecordatoriosManana == new List<string>() &&
                    r.HabitosManana == new List<ResumidorDiarioAgentResponseHabito>()
                );

                this.personaCuidadaID = 7;
                this.personaCuidadaNombre = "Alicia";

                #region Evento Agenda

                this.fechaOcurrenciaAgenda = DateTime.Today.AddDays(1).AddHours(10);

                this.eventoAgenda = new Mock<EventoAgenda>();
                this.eventoAgenda.Setup(s => s.Titulo).Returns("Turno con el cardiólogo");
                this.eventoAgenda.Setup(s => s.Tipo).Returns(Mock.Of<TipoEvento>(t => t.Descripcion == "Consulta médica"));
                this.eventoAgenda.Setup(s => s.ObtenerOcurrenciasEnRango(It.IsAny<IExpansorRecurrenciaDomainService>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<DateTime> { this.fechaOcurrenciaAgenda });

                this.eventoAgendaRepository
                    .Setup(s => s.GetAllByPersonaEnRango(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoAgenda> { this.eventoAgenda.Object });

                #endregion

                #region Evento Salud

                this.eventoSaludPasado = new Mock<EventoSalud>();
                this.eventoSaludPasado.Setup(s => s.Tipo).Returns(Mock.Of<TipoEvento>(t => t.Descripcion == "Síntoma"));
                this.eventoSaludPasado.Setup(s => s.Descripcion).Returns("Mareos al levantarse");
                this.eventoSaludPasado.Setup(s => s.FechaHora).Returns(DateTime.Now.AddHours(-2));

                this.eventoSaludRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoSalud> { this.eventoSaludPasado.Object });

                #endregion

                #region HabitoVida

                this.habitoVidaCumplido = new Mock<HabitoVida>();
                this.habitoVidaCumplido.Setup(s => s.Tipo).Returns(Mock.Of<TipoHabitoVida>(t => t.Descripcion == "Bienestar"));
                this.habitoVidaCumplido.Setup(s => s.Descripcion).Returns("Caminata diaria");
                this.habitoVidaCumplido.Setup(s => s.Realizaciones)
                    .Returns(new List<HabitoVidaRealizacion> { Mock.Of<HabitoVidaRealizacion>(r => r.FechaHoraRealizacion == DateTime.Today.AddHours(8)) });

                this.habitoVidaRepository
                    .Setup(s => s.GetByPersona(It.IsAny<int>()))
                    .Returns(new List<HabitoVida> { this.habitoVidaCumplido.Object });

                #endregion

                #region Estado Animo

                this.estadoAnimoAnterior = new Mock<PersonaEstadoAnimo>();
                this.estadoAnimoAnterior.Setup(s => s.ID).Returns(1);
                this.estadoAnimoAnterior.Setup(s => s.FechaHora).Returns(DateTime.Today.AddHours(9));
                this.estadoAnimoAnterior.Setup(s => s.EstadoAnimo).Returns(Mock.Of<EstadoAnimo>(e => e.Descripcion == "Cansada"));
                this.estadoAnimoAnterior.Setup(s => s.Observaciones).Returns("Cansada Obs");

                this.estadoAnimoPosterior = new Mock<PersonaEstadoAnimo>();
                this.estadoAnimoPosterior.Setup(s => s.ID).Returns(2);
                this.estadoAnimoPosterior.Setup(s => s.FechaHora).Returns(DateTime.Today.AddHours(15));
                this.estadoAnimoPosterior.Setup(s => s.EstadoAnimo).Returns(Mock.Of<EstadoAnimo>(e => e.Descripcion == "Contenta"));

                this.personaEstadoAnimoRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<PersonaEstadoAnimo>
                    {
                        this.estadoAnimoAnterior.Object,
                        this.estadoAnimoPosterior.Object
                    });

                #endregion

                this.resumidorDiarioAgent.Setup(s => s.ArmarResumen(It.IsAny<ResumidorTextoAgentRequest>(), It.IsAny<CancellationToken>())).ReturnsAsync(this.resumenGenerado);
            }

            private ResumenDiarioDataView Action()
            {
                return this.Target.Armar(this.personaCuidadaID, this.personaCuidadaNombre, It.IsAny<CancellationToken>()).Result;
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetAllByPersonaEnRango_del_EventoAgendaRepository()
            {
                // Arrange
                var inicio = DateTime.Now;

                // Action
                this.Action();

                // Assert
                var fin = DateTime.Now;
                this.eventoAgendaRepository.Verify(v => v.GetAllByPersonaEnRango(this.personaCuidadaID,
                                                                                 It.Is<DateTime>(d => d >= inicio && d <= fin),
                                                                                 DateTime.Today.AddDays(2)), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByFechas_del_EventoSaludRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSaludRepository.Verify(v => v.GetByFechas(this.personaCuidadaID,
                                                                     DateTime.Today,
                                                                     DateTime.Today.AddDays(1)), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByPersona_del_HabitoVidaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.habitoVidaRepository.Verify(v => v.GetByPersona(this.personaCuidadaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByFechas_del_PersonaEstadoAnimoRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaEstadoAnimoRepository.Verify(v => v.GetByFechas(this.personaCuidadaID,
                                                                            DateTime.Today,
                                                                            DateTime.Today.AddDays(1)), Times.Once);
            }

            [Fact]
            public void Retorna_null_si_no_hay_datos_en_ninguna_de_las_cuatro_fuentes()
            {
                // Arrange
                this.eventoAgendaRepository
                    .Setup(s => s.GetAllByPersonaEnRango(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoAgenda>());

                this.eventoSaludRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoSalud>());

                this.habitoVidaRepository
                    .Setup(s => s.GetByPersona(It.IsAny<int>()))
                    .Returns(new List<HabitoVida>());

                this.personaEstadoAnimoRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<PersonaEstadoAnimo>());

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void No_llama_al_ResumidorDiarioAgent_si_no_hay_datos_en_ninguna_de_las_cuatro_fuentes()
            {
                // Arrange
                this.eventoAgendaRepository
                    .Setup(s => s.GetAllByPersonaEnRango(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoAgenda>());

                this.eventoSaludRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoSalud>());

                this.habitoVidaRepository
                    .Setup(s => s.GetByPersona(It.IsAny<int>()))
                    .Returns(new List<HabitoVida>());

                this.personaEstadoAnimoRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<PersonaEstadoAnimo>());

                // Action
                this.Action();

                // Assert
                this.resumidorDiarioAgent.Verify(v => v.ArmarResumen(It.IsAny<ResumidorTextoAgentRequest>(),
                                                                     It.IsAny<CancellationToken>()), Times.Never);
            }

            [Fact]
            public void Llama_al_ResumidorDiarioAgent_si_solo_hay_EventosAgenda()
            {
                // Arrange
                this.eventoSaludRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoSalud>());

                this.habitoVidaRepository
                    .Setup(s => s.GetByPersona(It.IsAny<int>()))
                    .Returns(new List<HabitoVida>());

                this.personaEstadoAnimoRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<PersonaEstadoAnimo>());

                // Action
                this.Action();

                // Assert
                this.resumidorDiarioAgent.Verify(v => v.ArmarResumen(It.IsAny<ResumidorTextoAgentRequest>(),
                                                                     It.IsAny<CancellationToken>()), Times.Once);
            }

            [Fact]
            public void Llama_al_ResumidorDiarioAgent_si_solo_hay_EventosSalud()
            {
                // Arrange
                this.eventoAgendaRepository
                    .Setup(s => s.GetAllByPersonaEnRango(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoAgenda>());

                this.habitoVidaRepository
                    .Setup(s => s.GetByPersona(It.IsAny<int>()))
                    .Returns(new List<HabitoVida>());

                this.personaEstadoAnimoRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<PersonaEstadoAnimo>());

                // Action
                this.Action();

                // Assert
                this.resumidorDiarioAgent.Verify(v => v.ArmarResumen(It.IsAny<ResumidorTextoAgentRequest>(),
                                                                     It.IsAny<CancellationToken>()), Times.Once);
            }

            [Fact]
            public void Llama_al_ResumidorDiarioAgent_si_solo_hay_HabitosVida()
            {
                // Arrange
                this.eventoAgendaRepository
                    .Setup(s => s.GetAllByPersonaEnRango(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoAgenda>());

                this.eventoSaludRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoSalud>());

                this.personaEstadoAnimoRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<PersonaEstadoAnimo>());

                // Action
                this.Action();

                // Assert
                this.resumidorDiarioAgent.Verify(v => v.ArmarResumen(It.IsAny<ResumidorTextoAgentRequest>(),
                                                                     It.IsAny<CancellationToken>()), Times.Once);
            }

            [Fact]
            public void Llama_al_ResumidorDiarioAgent_si_solo_hay_EstadosAnimo()
            {
                // Arrange
                this.eventoAgendaRepository
                    .Setup(s => s.GetAllByPersonaEnRango(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoAgenda>());

                this.eventoSaludRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoSalud>());

                this.habitoVidaRepository
                    .Setup(s => s.GetByPersona(It.IsAny<int>()))
                    .Returns(new List<HabitoVida>());

                // Action
                this.Action();

                // Assert
                this.resumidorDiarioAgent.Verify(v => v.ArmarResumen(It.IsAny<ResumidorTextoAgentRequest>(),
                                                                     It.IsAny<CancellationToken>()), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ObtenerOcurrenciasEnRango_de_cada_EventoAgenda_recuperado()
            {
                // Arrange
                var inicio = DateTime.Now;

                // Action
                this.Action();

                // Assert
                var fin = DateTime.Now;
                this.eventoAgenda.Verify(v => v.ObtenerOcurrenciasEnRango(this.expansorRecurrenciaDomainService.Object,
                                                                          It.Is<DateTime>(d => d >= inicio && d <= fin),
                                                                          DateTime.Today.AddDays(2)), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ArmarResumen_del_ResumidorDiarioAgent()
            {
                // Arrange
                var fechaDesde = DateTime.Now;

                // Action
                this.Action();

                // Assert
                this.resumidorDiarioAgent.Verify(v => v.ArmarResumen(It.Is<ResumidorTextoAgentRequest>(r =>
                    r.NombrePersona == this.personaCuidadaNombre &&
                    r.FechaHoy >= fechaDesde && r.FechaHoy <= DateTime.Now &&
                    r.FechaManana == DateTime.Today.AddDays(1) &&
                    r.EventosAgenda.Any(e =>
                        e.Tipo == this.eventoAgenda.Object.Tipo.Descripcion &&
                        e.Descripcion == this.eventoAgenda.Object.Titulo &&
                        e.FechaHoraOcurrencia == this.fechaOcurrenciaAgenda &&
                        e.Finalizado == false) &&

                    r.EventosSalud.Any(e =>
                        e.Tipo == this.eventoSaludPasado.Object.Tipo.Descripcion &&
                        e.Descripcion == this.eventoSaludPasado.Object.Descripcion &&
                        e.FechaHoraOcurrencia == this.eventoSaludPasado.Object.FechaHora) &&

                    r.HabitosVida.Any(h =>
                        h.Tipo == this.habitoVidaCumplido.Object.Tipo.Descripcion &&
                        h.Descripcion == this.habitoVidaCumplido.Object.Descripcion &&
                        h.FechaHoraOcurrencia == this.habitoVidaCumplido.Object.Realizaciones.First().FechaHoraRealizacion) &&

                    r.EstadosAnimo.Any(e =>
                        e.Tipo == this.estadoAnimoAnterior.Object.EstadoAnimo.Descripcion &&
                        e.Descripcion == this.estadoAnimoAnterior.Object.Observaciones &&
                        e.FechaHoraOcurrencia == this.estadoAnimoAnterior.Object.FechaHora &&
                        e.Finalizado == true) &&
                    r.EstadosAnimo.Any(e =>
                        e.Tipo == this.estadoAnimoPosterior.Object.EstadoAnimo.Descripcion &&
                        e.Descripcion == this.estadoAnimoPosterior.Object.EstadoAnimo.Descripcion &&
                        e.FechaHoraOcurrencia == this.estadoAnimoPosterior.Object.FechaHora &&
                        e.Finalizado == false)),
                    It.IsAny<CancellationToken>()), Times.Once);
            }

            [Fact]
            public void Setea_el_ResumenAcotado_en_la_respuesta()
            {
                // Arrange
                Mock.Get(this.resumenGenerado).Setup(s => s.ResumenAcotado).Returns("Valor de prueba");

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.resumenGenerado.ResumenAcotado, resultado.ResumenAcotado);
            }

            [Fact]
            public void Setea_el_EstadoAnimo_en_la_respuesta()
            {
                // Arrange
                Mock.Get(this.resumenGenerado).Setup(s => s.EstadoAnimo).Returns("Valor de prueba");

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.resumenGenerado.EstadoAnimo, resultado.EstadoAnimo);
            }

            [Fact]
            public void Setea_el_ResumenHabitos_en_la_respuesta()
            {
                // Arrange
                Mock.Get(this.resumenGenerado).Setup(s => s.ResumenHabitos).Returns("Valor de prueba");

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.resumenGenerado.ResumenHabitos, resultado.ResumenHabitos);
            }

            [Fact]
            public void Setea_los_Habitos_en_la_respuesta()
            {
                // Arrange
                Mock.Get(this.resumenGenerado).Setup(s => s.Habitos).Returns(new List<ResumidorDiarioAgentResponseHabito>
                {
                    new ResumidorDiarioAgentResponseHabito{ Descripcion = "Descripcion", Completado = true }
                });

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equivalent(this.resumenGenerado.Habitos, resultado.Habitos);
            }

            [Fact]
            public void Setea_los_EventosSalud_en_la_respuesta()
            {
                // Arrange
                Mock.Get(this.resumenGenerado).Setup(s => s.EventosSalud).Returns(new List<ResumidorDiarioAgentResponseEventoSalud>
                {
                    new ResumidorDiarioAgentResponseEventoSalud{ Descripcion = "Descripcion", Hora = "08:45", ActividadHabitoAsociado = "Actividad X" }
                });

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equivalent(this.resumenGenerado.EventosSalud, resultado.EventosSalud);
            }

            [Fact]
            public void Setea_las_Recomendaciones_en_la_respuesta()
            {
                // Arrange
                Mock.Get(this.resumenGenerado).Setup(s => s.Recomendaciones).Returns(new List<string>
                {
                    "Dato Random 1"
                });

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equivalent(this.resumenGenerado.Recomendaciones, resultado.Recomendaciones);
            }

            [Fact]
            public void Setea_los_RecordatoriosHoy_en_la_respuesta()
            {
                // Arrange
                Mock.Get(this.resumenGenerado).Setup(s => s.RecordatoriosHoy).Returns(new List<string>
                {
                    "Dato Random 1"
                });

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equivalent(this.resumenGenerado.RecordatoriosHoy, resultado.RecordatoriosHoy);
            }

            [Fact]
            public void Setea_los_RecordatoriosManana_en_la_respuesta()
            {
                // Arrange
                Mock.Get(this.resumenGenerado).Setup(s => s.RecordatoriosManana).Returns(new List<string>
                {
                    "Dato Random 1"
                });

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equivalent(this.resumenGenerado.RecordatoriosManana, resultado.RecordatoriosManana);
            }

            [Fact]
            public void Setea_los_HabitosManana_en_la_respuesta()
            {
                // Arrange
                Mock.Get(this.resumenGenerado).Setup(s => s.HabitosManana).Returns(new List<ResumidorDiarioAgentResponseHabito>
                {
                    new ResumidorDiarioAgentResponseHabito{Descripcion = "Descripcion", Completado = false }
                });

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equivalent(this.resumenGenerado.HabitosManana, resultado.HabitosManana);
            }

            [Fact]
            public void Retorna_una_instancia_del_tipo_ResumenDiarioDataView()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<ResumenDiarioDataView>(resultado);
            }
        }
    }
}
