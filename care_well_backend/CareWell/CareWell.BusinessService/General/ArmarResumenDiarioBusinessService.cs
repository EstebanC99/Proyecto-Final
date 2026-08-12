using CareWell.BusinessService.Abstractions.General;
using CareWell.DataViews.General;
using CareWell.DocumentIntelligence.ResumidorDiario;
using CareWell.Domain.Agenda;
using CareWell.Domain.DomainServices.Agenda;
using CareWell.Repository.Agenda;
using CareWell.Repository.Salud;

namespace CareWell.BusinessService.General
{
    public class ArmarResumenDiarioBusinessService : IArmarResumenDiarioBusinessService
    {
        private IEventoAgendaRepository EventoAgendaRepository { get; set; }
        private IEventoSaludRepository EventoSaludRepository { get; set; }
        private IHabitoVidaRepository HabitoVidaRepository { get; set; }
        private IPersonaEstadoAnimoRepository PersonaEstadoAnimoRepository { get; set; }
        private IExpansorRecurrenciaDomainService ExpansorRecurrenciaDomainService { get; set; }
        private IResumidorDiarioAgent ResumidorDiarioAgent { get; set; }

        public ArmarResumenDiarioBusinessService(IEventoAgendaRepository eventoAgendaRepository,
                                                 IEventoSaludRepository eventoSaludRepository,
                                                 IHabitoVidaRepository habitoVidaRepository,
                                                 IPersonaEstadoAnimoRepository personaEstadoAnimoRepository,
                                                 IExpansorRecurrenciaDomainService expansorRecurrenciaDomainService,
                                                 IResumidorDiarioAgent resumidorDiarioAgent)
        {
            this.EventoAgendaRepository = eventoAgendaRepository;
            this.EventoSaludRepository = eventoSaludRepository;
            this.HabitoVidaRepository = habitoVidaRepository;
            this.PersonaEstadoAnimoRepository = personaEstadoAnimoRepository;
            this.ExpansorRecurrenciaDomainService = expansorRecurrenciaDomainService;
            this.ResumidorDiarioAgent = resumidorDiarioAgent;
        }

        public async Task<ResumenDiarioDataView> Armar(int personaCuidadaID, string personaCuidadaNombre, CancellationToken cancellationToken)
        {
            var fechaDesde = DateTime.Now;
            var fechaHasta = DateTime.Today.AddDays(1);

            var eventosAgenda = this.EventoAgendaRepository.GetAllByPersonaEnRango(personaCuidadaID, fechaDesde, fechaHasta.AddDays(1));
            var eventosSalud = this.EventoSaludRepository.GetByFechas(personaCuidadaID, fechaDesde.Date, fechaHasta);
            var habitosVida = this.HabitoVidaRepository.GetByPersona(personaCuidadaID);
            var estadosAnimo = this.PersonaEstadoAnimoRepository.GetByFechas(personaCuidadaID, fechaDesde.Date, fechaHasta);

            var eventosRegistrados = eventosAgenda.Count + eventosSalud.Count + habitosVida.Count + estadosAnimo.Count;

            if (eventosRegistrados == default)
                return new ResumenDiarioDataView { GeneradoEn = DateTime.Now };

            var request = new ResumidorTextoAgentRequest
            {
                NombrePersona = personaCuidadaNombre,
                FechaHoy = fechaDesde,
                FechaManana = fechaHasta,
                EventosAgenda = this.ObtenerEventosAgenda(eventosAgenda, fechaDesde, fechaHasta.AddDays(1)),
                EventosSalud = eventosSalud.Select(e => new EventoRequest
                {
                    Tipo = e.Tipo.Descripcion,
                    Descripcion = e.Descripcion,
                    FechaHoraOcurrencia = e.FechaHora,
                    Finalizado = e.FechaHora < fechaDesde
                }).ToList(),
                HabitosVida = habitosVida.Select(h => new EventoRequest
                {
                    Tipo = h.Tipo.Descripcion,
                    Descripcion = h.Descripcion,
                    FechaHoraOcurrencia = h.Realizaciones
                        .Where(r => r.FechaHoraRealizacion.Date == fechaDesde.Date)
                        .Select(r => r.FechaHoraRealizacion)
                        .Cast<DateTime?>()
                        .FirstOrDefault(),
                    Finalizado = h.Realizaciones.Any(r => r.FechaHoraRealizacion.Date == fechaDesde.Date)
                }).ToList(),
                EstadosAnimo = estadosAnimo.Select(e => new EventoRequest
                {
                    Tipo = e.EstadoAnimo.Descripcion,
                    Descripcion = e.Observaciones ?? e.EstadoAnimo.Descripcion,
                    FechaHoraOcurrencia = e.FechaHora,
                    Finalizado = estadosAnimo.Any(es => es.ID > e.ID)
                }).ToList()
            };

            var response = await this.ResumidorDiarioAgent.ArmarResumen(request, cancellationToken);

            var resumenDiario = new ResumenDiarioDataView
            {
                ResumenAcotado = response.ResumenAcotado,
                EstadoAnimo = response.EstadoAnimo,

                ResumenHabitos = response.ResumenHabitos,
                Habitos = response.Habitos.Select(h => new ResumenDiarioHabitosDataView
                {
                    Descripcion = h.Descripcion,
                    Completado = h.Completado,
                }).ToList(),

                EventosSalud = response.EventosSalud.Select(e => new ResumenDiarioEventosSaludDataView
                {
                    Descripcion = e.Descripcion,
                    Hora = e.Hora,
                    ActividadHabitoAsociado = e.ActividadHabitoAsociado
                }).ToList(),

                Recomendaciones = response.Recomendaciones,
                RecordatoriosHoy = response.RecordatoriosHoy,
                RecordatoriosManana = response.RecordatoriosManana,
                HabitosManana = response.HabitosManana.Select(h => new ResumenDiarioHabitosDataView
                {
                    Descripcion = h.Descripcion,
                    Completado = h.Completado,
                }).ToList(),
                GeneradoEn = DateTime.Now
            };

            return resumenDiario;
        }

        private List<EventoRequest> ObtenerEventosAgenda(List<EventoAgenda> eventosAgenda, DateTime fechaDesde, DateTime fechaHasta)
        {
            var ocurrencias = new List<EventoRequest>();

            foreach (var eventoAgenda in eventosAgenda)
            {
                var fechasOcurrencia = eventoAgenda.ObtenerOcurrenciasEnRango(this.ExpansorRecurrenciaDomainService, fechaDesde, fechaHasta);

                foreach (var fechaOcurrencia in fechasOcurrencia)
                {
                    ocurrencias.Add(new EventoRequest
                    {
                        Tipo = eventoAgenda.Tipo.Descripcion,
                        Descripcion = eventoAgenda.Titulo,
                        FechaHoraOcurrencia = fechaOcurrencia,
                        Finalizado = false
                    });
                }
            }

            return ocurrencias.OrderBy(o => o.FechaHoraOcurrencia).ToList();
        }
    }
}
