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
            private const string ResumenGenerado = "Resumen del día de Alicia.";

            private Mock<Persona> personaCuidada;
            private CancellationTokenSource cancellationTokenSource;
            private CancellationToken cancellationToken;

            private Mock<EventoAgenda> eventoAgenda;
            private DateTime fechaOcurrenciaAgenda;

            private Mock<EventoSalud> eventoSaludPasado;
            private DateTime fechaHoraEventoSaludPasado;

            private Mock<HabitoVida> habitoVidaCumplido;
            private DateTime fechaRealizacionHabito;

            private Mock<PersonaEstadoAnimo> estadoAnimoAnterior;
            private Mock<PersonaEstadoAnimo> estadoAnimoPosterior;

            /// <summary>Request efectivamente enviado al agente de IA, capturado en el Setup.</summary>
            private ResumidorTextoAgentRequest requestEnviado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.personaCuidada = new Mock<Persona>();
                this.personaCuidada.Setup(s => s.ID).Returns(7);
                this.personaCuidada.Setup(s => s.Nombre).Returns("Alicia");

                this.cancellationTokenSource = new CancellationTokenSource();
                this.cancellationToken = this.cancellationTokenSource.Token;

                this.ConfigurarEventoAgenda();
                this.ConfigurarEventoSalud();
                this.ConfigurarHabitoVida();
                this.ConfigurarEstadosAnimo();

                this.resumidorDiarioAgent
                    .Setup(s => s.ArmarResumen(It.IsAny<ResumidorTextoAgentRequest>(), It.IsAny<CancellationToken>()))
                    .Callback<ResumidorTextoAgentRequest, CancellationToken>((request, _) => this.requestEnviado = request)
                    .ReturnsAsync(ResumenGenerado);
            }

            private string? Action()
            {
                return this.Target.Armar(this.personaCuidada.Object, this.cancellationToken).Result;
            }

            #region Rango de fechas y consulta a los repositorios

            [Fact]
            public void Llama_una_vez_al_metodo_GetAllByPersonaEnRango_del_EventoAgendaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgendaRepository.Verify(v => v.GetAllByPersonaEnRango(this.personaCuidada.Object.ID,
                                                                                 It.IsAny<DateTime>(),
                                                                                 It.IsAny<DateTime>()), Times.Once);
            }

            [Fact]
            public void Consulta_la_Agenda_desde_el_momento_actual_hasta_el_final_del_dia_de_manana()
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
            public void Consulta_los_EventosSalud_del_dia_de_hoy_completo()
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
            public void Consulta_los_EstadosAnimo_del_dia_de_hoy_completo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaEstadoAnimoRepository.Verify(v => v.GetByFechas(this.personaCuidada.Object.ID,
                                                                            DateTime.Today,
                                                                            DateTime.Today.AddDays(1)), Times.Once);
            }

            #endregion

            #region Expansion de ocurrencias de Agenda

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
            public void Genera_un_EventoRequest_por_cada_ocurrencia_expandida()
            {
                // Arrange
                this.eventoAgenda
                    .Setup(s => s.ObtenerOcurrenciasEnRango(It.IsAny<IExpansorRecurrenciaDomainService>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<DateTime>
                    {
                        DateTime.Today.AddDays(1).AddHours(10),
                        DateTime.Today.AddDays(1).AddHours(18)
                    });

                // Action
                this.Action();

                // Assert
                Assert.Equal(2, this.requestEnviado.EventosAgenda.Count);
            }

            [Fact]
            public void Ordena_los_EventosAgenda_por_FechaHoraOcurrencia_ascendente()
            {
                // Arrange
                var ocurrenciaTardia = DateTime.Today.AddDays(1).AddHours(18);
                var ocurrenciaTemprana = DateTime.Today.AddDays(1).AddHours(10);

                this.eventoAgenda
                    .Setup(s => s.ObtenerOcurrenciasEnRango(It.IsAny<IExpansorRecurrenciaDomainService>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<DateTime> { ocurrenciaTardia, ocurrenciaTemprana });

                // Action
                this.Action();

                // Assert
                Assert.Equal(ocurrenciaTemprana, this.requestEnviado.EventosAgenda.First().FechaHoraOcurrencia);
                Assert.Equal(ocurrenciaTardia, this.requestEnviado.EventosAgenda.Last().FechaHoraOcurrencia);
            }

            #endregion

            #region Short circuit por ausencia de datos

            [Fact]
            public void Retorna_null_si_no_hay_datos_en_ninguna_de_las_cuatro_fuentes()
            {
                // Arrange
                this.ConfigurarTodasLasFuentesVacias();

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void No_llama_al_ResumidorDiarioAgent_si_no_hay_datos_en_ninguna_de_las_cuatro_fuentes()
            {
                // Arrange
                this.ConfigurarTodasLasFuentesVacias();

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
                this.ConfigurarTodasLasFuentesVacias();
                this.eventoAgendaRepository
                    .Setup(s => s.GetAllByPersonaEnRango(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoAgenda> { this.eventoAgenda.Object });

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
                this.ConfigurarTodasLasFuentesVacias();
                this.eventoSaludRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoSalud> { this.eventoSaludPasado.Object });

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
                this.ConfigurarTodasLasFuentesVacias();
                this.habitoVidaRepository
                    .Setup(s => s.GetByPersona(It.IsAny<int>()))
                    .Returns(new List<HabitoVida> { this.habitoVidaCumplido.Object });

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
                this.ConfigurarTodasLasFuentesVacias();
                this.personaEstadoAnimoRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<PersonaEstadoAnimo> { this.estadoAnimoPosterior.Object });

                // Action
                this.Action();

                // Assert
                this.resumidorDiarioAgent.Verify(v => v.ArmarResumen(It.IsAny<ResumidorTextoAgentRequest>(),
                                                                     It.IsAny<CancellationToken>()), Times.Once);
            }

            #endregion

            #region Cabecera del request

            [Fact]
            public void Envia_el_Nombre_de_la_PersonaCuidada_en_el_request()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.personaCuidada.Object.Nombre, this.requestEnviado.NombrePersona);
            }

            [Fact]
            public void Envia_FechaHoy_con_la_fecha_del_dia_de_hoy()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(DateTime.Today, this.requestEnviado.FechaHoy.Date);
            }

            [Fact]
            public void Envia_FechaManana_con_la_fecha_del_dia_siguiente()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(DateTime.Today.AddDays(1), this.requestEnviado.FechaManana);
            }

            #endregion

            #region Mapeo de EventosAgenda

            [Fact]
            public void Mapea_la_Descripcion_del_TipoEvento_como_Tipo_en_los_EventosAgenda()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.eventoAgenda.Object.Tipo.Descripcion, this.requestEnviado.EventosAgenda.First().Tipo);
            }

            [Fact]
            public void Mapea_el_Titulo_del_EventoAgenda_como_Descripcion_en_los_EventosAgenda()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.eventoAgenda.Object.Titulo, this.requestEnviado.EventosAgenda.First().Descripcion);
            }

            [Fact]
            public void Mapea_la_fecha_de_ocurrencia_expandida_en_los_EventosAgenda()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.fechaOcurrenciaAgenda, this.requestEnviado.EventosAgenda.First().FechaHoraOcurrencia);
            }

            [Fact]
            public void Marca_los_EventosAgenda_como_no_finalizados()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.False(this.requestEnviado.EventosAgenda.First().Finalizado);
            }

            #endregion

            #region Mapeo de EventosSalud

            [Fact]
            public void Mapea_la_Descripcion_del_TipoEvento_como_Tipo_en_los_EventosSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.eventoSaludPasado.Object.Tipo.Descripcion, this.requestEnviado.EventosSalud.First().Tipo);
            }

            [Fact]
            public void Mapea_la_Descripcion_del_EventoSalud_en_los_EventosSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.eventoSaludPasado.Object.Descripcion, this.requestEnviado.EventosSalud.First().Descripcion);
            }

            [Fact]
            public void Mapea_la_FechaHora_del_EventoSalud_en_los_EventosSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.fechaHoraEventoSaludPasado, this.requestEnviado.EventosSalud.First().FechaHoraOcurrencia);
            }

            [Fact]
            public void Marca_como_finalizado_el_EventoSalud_cuya_FechaHora_ya_paso()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.True(this.requestEnviado.EventosSalud.First().Finalizado);
            }

            [Fact]
            public void Marca_como_no_finalizado_el_EventoSalud_cuya_FechaHora_es_futura()
            {
                // Arrange
                var eventoSaludFuturo = new Mock<EventoSalud>();
                eventoSaludFuturo.Setup(s => s.Tipo).Returns(Mock.Of<TipoEvento>(t => t.Descripcion == "Control"));
                eventoSaludFuturo.Setup(s => s.Descripcion).Returns("Control de presión");
                eventoSaludFuturo.Setup(s => s.FechaHora).Returns(DateTime.Now.AddHours(2));

                this.eventoSaludRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoSalud> { eventoSaludFuturo.Object });

                // Action
                this.Action();

                // Assert
                Assert.False(this.requestEnviado.EventosSalud.First().Finalizado);
            }

            #endregion

            #region Mapeo de HabitosVida

            [Fact]
            public void Mapea_el_nombre_de_la_entidad_HabitoVida_como_Tipo_en_los_HabitosVida()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(nameof(HabitoVida), this.requestEnviado.HabitosVida.First().Tipo);
            }

            [Fact]
            public void Mapea_la_Descripcion_del_HabitoVida_en_los_HabitosVida()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.habitoVidaCumplido.Object.Descripcion, this.requestEnviado.HabitosVida.First().Descripcion);
            }

            [Fact]
            public void Marca_como_finalizado_el_HabitoVida_con_una_realizacion_del_dia_de_hoy()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.True(this.requestEnviado.HabitosVida.First().Finalizado);
            }

            [Fact]
            public void Mapea_la_FechaHoraRealizacion_de_hoy_del_HabitoVida_cumplido()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.fechaRealizacionHabito, this.requestEnviado.HabitosVida.First().FechaHoraOcurrencia);
            }

            [Fact]
            public void Marca_como_no_finalizado_el_HabitoVida_sin_realizaciones_del_dia_de_hoy()
            {
                // Arrange
                this.habitoVidaRepository
                    .Setup(s => s.GetByPersona(It.IsAny<int>()))
                    .Returns(new List<HabitoVida> { this.ConstruirHabitoVidaSinRealizacionesDeHoy().Object });

                // Action
                this.Action();

                // Assert
                Assert.False(this.requestEnviado.HabitosVida.First().Finalizado);
            }

            [Fact]
            public void Setea_la_FechaHoraOcurrencia_en_el_valor_por_defecto_si_el_HabitoVida_no_tiene_realizaciones_de_hoy()
            {
                // Arrange
                this.habitoVidaRepository
                    .Setup(s => s.GetByPersona(It.IsAny<int>()))
                    .Returns(new List<HabitoVida> { this.ConstruirHabitoVidaSinRealizacionesDeHoy().Object });

                // Action
                this.Action();

                // Assert
                Assert.Equal(default(DateTime), this.requestEnviado.HabitosVida.First().FechaHoraOcurrencia);
            }

            #endregion

            #region Mapeo de EstadosAnimo

            [Fact]
            public void Mapea_el_nombre_de_la_entidad_EstadoAnimo_como_Tipo_en_los_EstadosAnimo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(nameof(EstadoAnimo), this.requestEnviado.EstadosAnimo.First().Tipo);
            }

            [Fact]
            public void Mapea_la_Descripcion_del_EstadoAnimo_en_los_EstadosAnimo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.estadoAnimoAnterior.Object.EstadoAnimo.Descripcion, this.requestEnviado.EstadosAnimo.First().Descripcion);
            }

            [Fact]
            public void Mapea_la_FechaHora_del_PersonaEstadoAnimo_en_los_EstadosAnimo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.estadoAnimoAnterior.Object.FechaHora, this.requestEnviado.EstadosAnimo.First().FechaHoraOcurrencia);
            }

            [Fact]
            public void Marca_como_finalizado_el_EstadoAnimo_superado_por_otro_registro_posterior()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.True(this.requestEnviado.EstadosAnimo.First().Finalizado);
            }

            [Fact]
            public void Marca_como_no_finalizado_el_ultimo_EstadoAnimo_registrado()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.False(this.requestEnviado.EstadosAnimo.Last().Finalizado);
            }

            #endregion

            #region Invocacion del agente de IA

            [Fact]
            public void Llama_una_vez_al_metodo_ArmarResumen_del_ResumidorDiarioAgent()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.resumidorDiarioAgent.Verify(v => v.ArmarResumen(It.IsAny<ResumidorTextoAgentRequest>(),
                                                                     It.IsAny<CancellationToken>()), Times.Once);
            }

            [Fact]
            public void Propaga_el_CancellationToken_recibido_al_ResumidorDiarioAgent()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.resumidorDiarioAgent.Verify(v => v.ArmarResumen(It.IsAny<ResumidorTextoAgentRequest>(),
                                                                     this.cancellationToken), Times.Once);
            }

            [Fact]
            public void Retorna_el_texto_devuelto_por_el_ResumidorDiarioAgent()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(ResumenGenerado, resultado);
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

            #endregion

            #region Metodos Privados

            private void ConfigurarEventoAgenda()
            {
                this.fechaOcurrenciaAgenda = DateTime.Today.AddDays(1).AddHours(10);

                this.eventoAgenda = new Mock<EventoAgenda>();
                this.eventoAgenda.Setup(s => s.Titulo).Returns("Turno con el cardiólogo");
                this.eventoAgenda.Setup(s => s.Tipo).Returns(Mock.Of<TipoEvento>(t => t.Descripcion == "Consulta médica"));
                this.eventoAgenda
                    .Setup(s => s.ObtenerOcurrenciasEnRango(It.IsAny<IExpansorRecurrenciaDomainService>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<DateTime> { this.fechaOcurrenciaAgenda });

                this.eventoAgendaRepository
                    .Setup(s => s.GetAllByPersonaEnRango(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoAgenda> { this.eventoAgenda.Object });
            }

            private void ConfigurarEventoSalud()
            {
                this.fechaHoraEventoSaludPasado = DateTime.Now.AddHours(-2);

                this.eventoSaludPasado = new Mock<EventoSalud>();
                this.eventoSaludPasado.Setup(s => s.Tipo).Returns(Mock.Of<TipoEvento>(t => t.Descripcion == "Síntoma"));
                this.eventoSaludPasado.Setup(s => s.Descripcion).Returns("Mareos al levantarse");
                this.eventoSaludPasado.Setup(s => s.FechaHora).Returns(this.fechaHoraEventoSaludPasado);

                this.eventoSaludRepository
                    .Setup(s => s.GetByFechas(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
                    .Returns(new List<EventoSalud> { this.eventoSaludPasado.Object });
            }

            private void ConfigurarHabitoVida()
            {
                this.fechaRealizacionHabito = DateTime.Today.AddHours(8);

                var realizacion = new Mock<HabitoVidaRealizacion>();
                realizacion.Setup(s => s.FechaHoraRealizacion).Returns(this.fechaRealizacionHabito);

                this.habitoVidaCumplido = new Mock<HabitoVida>();
                this.habitoVidaCumplido.Setup(s => s.Descripcion).Returns("Caminata diaria");
                this.habitoVidaCumplido.Setup(s => s.Realizaciones).Returns(new List<HabitoVidaRealizacion> { realizacion.Object });

                this.habitoVidaRepository
                    .Setup(s => s.GetByPersona(It.IsAny<int>()))
                    .Returns(new List<HabitoVida> { this.habitoVidaCumplido.Object });
            }

            private Mock<HabitoVida> ConstruirHabitoVidaSinRealizacionesDeHoy()
            {
                var realizacionDeAyer = new Mock<HabitoVidaRealizacion>();
                realizacionDeAyer.Setup(s => s.FechaHoraRealizacion).Returns(DateTime.Today.AddDays(-1).AddHours(8));

                var habitoVida = new Mock<HabitoVida>();
                habitoVida.Setup(s => s.Descripcion).Returns("Meditación");
                habitoVida.Setup(s => s.Realizaciones).Returns(new List<HabitoVidaRealizacion> { realizacionDeAyer.Object });

                return habitoVida;
            }

            private void ConfigurarEstadosAnimo()
            {
                this.estadoAnimoAnterior = new Mock<PersonaEstadoAnimo>();
                this.estadoAnimoAnterior.Setup(s => s.ID).Returns(1);
                this.estadoAnimoAnterior.Setup(s => s.FechaHora).Returns(DateTime.Today.AddHours(9));
                this.estadoAnimoAnterior.Setup(s => s.EstadoAnimo).Returns(Mock.Of<EstadoAnimo>(e => e.Descripcion == "Cansada"));

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
            }

            private void ConfigurarTodasLasFuentesVacias()
            {
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
            }

            #endregion
        }
    }
}
