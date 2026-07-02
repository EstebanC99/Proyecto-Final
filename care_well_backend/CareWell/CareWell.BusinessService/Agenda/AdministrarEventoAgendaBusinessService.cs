using CareWell.BusinessService.Abstractions.Agenda;
using CareWell.BusinessService.Abstractions.Salud;
using CareWell.Commands.Agenda;
using CareWell.DataViews.Agenda;
using CareWell.Domain.Agenda;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Agenda;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Agenda;
using CareWell.Global.Constantes.Agenda;
using CareWell.Global.Enumeraciones.Agenda;
using CareWell.Queries.Agenda;
using CareWell.Repository;
using CareWell.Repository.Agenda;
using CareWell.Security;

namespace CareWell.BusinessService.Agenda
{
    public class AdministrarEventoAgendaBusinessService : BusinessService, IAdministrarEventoAgendaBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IBaseFactory Factory { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IEventoAgendaRepository EventoAgendaRepository { get; set; }
        private IExpansorRecurrenciaDomainService ExpansorRecurrenciaDomainService { get; set; }
        private ISerializadorFechasExceptuadasDomainService SerializadorFechasExceptuadasDomainService { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }
        private IGenerarEventoSaludBusinessService GenerarEventoSaludBusinessService { get; set; }

        public AdministrarEventoAgendaBusinessService(IUnitOfWork unitOfWork,
                                                      IUserContext userContext,
                                                      IBaseFactory baseFactory,
                                                      IEntityLoaderDomainService entityLoaderDomainService,
                                                      IEventoAgendaRepository eventoAgendaRepository,
                                                      IExpansorRecurrenciaDomainService expansorRecurrenciaDomainService,
                                                      ISerializadorFechasExceptuadasDomainService serializadorFechasExceptuadasDomainService,
                                                      IValidadorPermisoAccion validadorPermisoAccion,
                                                      IGenerarEventoSaludBusinessService generarEventoSaludBusinessService)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.Factory = baseFactory;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.EventoAgendaRepository = eventoAgendaRepository;
            this.ExpansorRecurrenciaDomainService = expansorRecurrenciaDomainService;
            this.SerializadorFechasExceptuadasDomainService = serializadorFechasExceptuadasDomainService;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
            this.GenerarEventoSaludBusinessService = generarEventoSaludBusinessService;
        }

        public List<OcurrenciaEventoAgendaDataView> ObtenerOcurrencias(ObtenerEventosAgendaQuery query)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var persona = this.EntityLoaderDomainService.GetByID<Persona>(query.PersonaID);
            var ocurrenciasDataView = new List<OcurrenciaEventoAgendaDataView>();

            this.ValidadorPermisoAccion.ValidarVisualizacion(persona, usuario.Persona);

            this.GenerarEventoSaludBusinessService.GenerarPendientes(persona.ID);

            var eventos = this.EventoAgendaRepository.GetAllByPersonaEnRango(persona.ID, query.FechaDesde, query.FechaHasta);

            foreach (var evento in eventos)
            {
                foreach (var fechaOcurrencia in evento.ObtenerOcurrenciasEnRango(this.ExpansorRecurrenciaDomainService, query.FechaDesde, query.FechaHasta))
                {
                    ocurrenciasDataView.Add(new OcurrenciaEventoAgendaDataView
                    {
                        EventoAgendaID = evento.ID,
                        PersonaID = evento.Persona.ID,
                        Titulo = evento.Titulo,
                        Descripcion = evento.Descripcion,
                        Tipo = new DataViews.BaseEntityDataView
                        {
                            ID = evento.Tipo.ID,
                            Descripcion = evento.Tipo.Descripcion
                        },
                        FechaHoraInicio = fechaOcurrencia,
                        FechaHoraFin = fechaOcurrencia.Add(evento.Duracion),
                        EsRecurrente = evento.ReglaRecurrencia != null,
                        GenerarEventoSalud = evento.GenerarEventoSalud,
                        MinutosAnticipacionRecordatorio = evento.MinutosAnticipacionRecordatorio
                    });
                }
            }

            return ocurrenciasDataView
                .OrderBy(o => o.FechaHoraInicio)
                .ToList();
        }

        public void Crear(CrearEventoAgendaCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);

            var crearEventoAgenda = new CrearEventoAgenda
            (
                Persona: this.EntityLoaderDomainService.GetByID<Persona>(command.PersonaID),
                Creador: usuario.Persona,
                Titulo: command.Titulo,
                Descripcion: command.Descripcion,
                Tipo: this.EntityLoaderDomainService.GetByID<TipoEvento>(command.TipoEventoID),
                FechaHoraInicio: command.FechaHoraInicio,
                Duracion: TimeSpan.FromMinutes(command.DuracionMinutos),
                Recurrencia: MapearRecurrencia(command),
                GenerarEventoSalud: command.GenerarEventoSalud,
                MinutosAnticipacionRecordatorio: command.MinutosAnticipacionRecordatorio
            );

            var eventoAgenda = this.Factory.Crear<EventoAgenda>();

            eventoAgenda.Crear(crearEventoAgenda,
                               this.ExpansorRecurrenciaDomainService,
                               this.ValidadorPermisoAccion);

            this.EventoAgendaRepository.Add(eventoAgenda);

            this.UnitOfWork.SaveChanges();
        }

        public void Modificar(ModificarEventoAgendaCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var eventoAgenda = this.EventoAgendaRepository.GetByID(command.EventoAgendaID);

            var modificarEventoAgenda = new ModificarEventoAgenda
            (
                Solicitante: usuario.Persona,
                Titulo: command.Titulo,
                Descripcion: command.Descripcion,
                Tipo: this.EntityLoaderDomainService.GetByID<TipoEvento>(command.TipoEventoID),
                FechaHoraInicio: command.FechaHoraInicio,
                Duracion: TimeSpan.FromMinutes(command.DuracionMinutos),
                Recurrencia: MapearRecurrencia(command),
                GenerarEventoSalud: command.GenerarEventoSalud,
                MinutosAnticipacionRecordatorio: command.MinutosAnticipacionRecordatorio
            );

            eventoAgenda.Modificar(modificarEventoAgenda,
                                   this.ExpansorRecurrenciaDomainService,
                                   this.ValidadorPermisoAccion);

            this.UnitOfWork.SaveChanges();
        }

        public void Eliminar(int eventoAgendaID)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var eventoAgenda = this.EventoAgendaRepository.GetByID(eventoAgendaID);

            eventoAgenda.Eliminar(this.ValidadorPermisoAccion,
                                  usuario.Persona);

            this.EventoAgendaRepository.Remove(eventoAgenda);

            this.UnitOfWork.SaveChanges();
        }

        public void CancelarOcurrencia(CancelarOcurrenciaEventoAgendaCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var eventoAgenda = this.EventoAgendaRepository.GetByID(command.EventoAgendaID);

            eventoAgenda.CancelarOcurrencia(command.FechaOcurrencia,
                                            usuario.Persona,
                                            this.SerializadorFechasExceptuadasDomainService,
                                            this.ValidadorPermisoAccion);

            this.UnitOfWork.SaveChanges();
        }

        #region Metodos Privados

        private static DefinirRecurrenciaEventoAgenda? MapearRecurrencia(CrearEventoAgendaCommand command)
        {
            if (!command.FrecuenciaRecurrenciaID.HasValue)
                return null;

            return new DefinirRecurrenciaEventoAgenda
            (
                FrecuenciaRecurrencia: (FrecuenciaRecurrenciaEnum)command.FrecuenciaRecurrenciaID,
                Intervalo: command.IntervaloRecurrencia ?? IntervalosAgenda.IntervaloPorDefecto,
                FechaFin: command.FechaFinRecurrencia
            );
        }

        #endregion
    }
}
