using CareWell.BusinessService.General;
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
            private readonly string resumenGenerado = "Resumen del día de Alicia.";

            private Mock<Persona> personaCuidada;

            private Mock<EventoAgenda> eventoAgenda;
            private DateTime fechaOcurrenciaAgenda;

            private Mock<EventoSalud> eventoSaludPasado;

            private Mock<HabitoVida> habitoVidaCumplido;

            private Mock<PersonaEstadoAnimo> estadoAnimoAnterior;
            private Mock<PersonaEstadoAnimo> estadoAnimoPosterior;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.personaCuidada = new Mock<Persona>();
                this.personaCuidada.Setup(s => s.ID).Returns(7);
                this.personaCuidada.Setup(s => s.Nombre).Returns("Alicia");

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

            private string? Action()
            {
                return this.Target.Armar(this.personaCuidada.Object, It.IsAny<CancellationToken>()).Result;
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
                this.eventoAgendaRepository.Verify(v => v.GetAllByPersonaEnRango(this.personaCuidada.Object.ID,
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
                this.eventoSaludRepository.Verify(v => v.GetByFechas(this.personaCuidada.Object.ID,
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
                this.habitoVidaRepository.Verify(v => v.GetByPersona(this.personaCuidada.Object.ID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByFechas_del_PersonaEstadoAnimoRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaEstadoAnimoRepository.Verify(v => v.GetByFechas(this.personaCuidada.Object.ID,
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
                    r.NombrePersona == this.personaCuidada.Object.Nombre &&
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
            public void Retorna_el_texto_devuelto_por_el_ResumidorDiarioAgent()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.resumenGenerado, resultado);
            }

            [Fact]
            public void Retorna_null_si_el_ResumidorDiarioAgent_devuelve_null()
            {
                // Arrange
                this.resumidorDiarioAgent
                    .Setup(s => s.ArmarResumen(It.IsAny<ResumidorTextoAgentRequest>(), It.IsAny<CancellationToken>()))
                    .ReturnsAsync((string?)null);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }
        }
    }
}
