using CareWell.BusinessService.Abstractions.Salud;
using CareWell.Domain.DomainServices.Agenda;
using CareWell.Domain.Factories;
using CareWell.Domain.Salud;
using CareWell.Repository;
using CareWell.Repository.Agenda;
using CareWell.Repository.Salud;

namespace CareWell.BusinessService.Salud
{
    public class GenerarEventoSaludBusinessService : BusinessService, IGenerarEventoSaludBusinessService
    {
        private IBaseFactory Factory { get; set; }
        private IEventoAgendaRepository EventoAgendaRepository { get; set; }
        private IEventoSaludRepository EventoSaludRepository { get; set; }
        private IExpansorRecurrenciaDomainService ExpansorRecurrenciaDomainService { get; set; }

        public GenerarEventoSaludBusinessService(IUnitOfWork unitOfWork,
                                                 IBaseFactory factory,
                                                 IEventoAgendaRepository eventoAgendaRepository,
                                                 IEventoSaludRepository eventoSaludRepository,
                                                 IExpansorRecurrenciaDomainService expansorRecurrenciaDomainService)
            : base(unitOfWork)
        {
            this.Factory = factory;
            this.EventoAgendaRepository = eventoAgendaRepository;
            this.EventoSaludRepository = eventoSaludRepository;
            this.ExpansorRecurrenciaDomainService = expansorRecurrenciaDomainService;
        }

        public void GenerarPendientes(int personaID)
        {
            var fechaHoraActual = DateTime.Now;

            var eventosAgenda = this.EventoAgendaRepository.GetAllWithGeneracionEventoSaludPendiente(personaID, fechaHoraActual);

            foreach (var eventoAgenda in eventosAgenda)
            {
                var ocurrencias = eventoAgenda.ObtenerOcurrencias(this.ExpansorRecurrenciaDomainService,
                                                                  fechaHoraActual);

                foreach (var fechaOcurrencia in ocurrencias)
                {
                    if (this.EventoSaludRepository.ExistePorOrigen(eventoAgenda.ID, fechaOcurrencia))
                        continue;

                    var eventoSalud = this.Factory.Crear<EventoSalud>();

                    eventoSalud.GenerarDesdeAgenda(eventoAgenda, fechaOcurrencia);

                    this.EventoSaludRepository.Add(eventoSalud);
                }

                eventoAgenda.ActualizarUltimaGeneracionEventoSalud(fechaHoraActual);
            }

            this.UnitOfWork.SaveChanges();
        }
    }
}
