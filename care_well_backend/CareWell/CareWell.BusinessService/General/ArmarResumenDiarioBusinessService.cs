using CareWell.DocumentIntelligence.ResumidorDiario;
using CareWell.Domain.Agenda;
using CareWell.Domain.DomainServices.Agenda;
using CareWell.Domain.DomainServices.General;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Repository.Agenda;
using CareWell.Repository.Salud;

namespace CareWell.BusinessService.General
{
    public class ArmarResumenDiarioBusinessService : IArmarResumenDiarioDomainService
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

        public async Task<string?> Armar(Persona personaCuidada, CancellationToken cancellationToken)
        {
            var fechaDesde = DateTime.Now;
            var fechaHasta = DateTime.Today.AddDays(1);

            var eventosAgenda = this.EventoAgendaRepository.GetAllByPersonaEnRango(personaCuidada.ID, fechaDesde, fechaHasta.AddDays(1));
            var eventosSalud = this.EventoSaludRepository.GetByFechas(personaCuidada.ID, fechaDesde.Date, fechaHasta);
            var habitosVida = this.HabitoVidaRepository.GetByPersona(personaCuidada.ID);
            var estadosAnimo = this.PersonaEstadoAnimoRepository.GetByFechas(personaCuidada.ID, fechaDesde.Date, fechaHasta);

            var eventosRegistrados = eventosAgenda.Count + eventosSalud.Count + habitosVida.Count + estadosAnimo.Count;

            if (eventosRegistrados == default)
                return null;

            var request = new ResumidorTextoAgentRequest
            {
                NombrePersona = personaCuidada.Nombre,
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

            return await this.ResumidorDiarioAgent.ArmarResumen(request, cancellationToken);
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
