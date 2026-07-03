using CareWell.BusinessService.Abstractions.Salud;
using CareWell.Commands.Salud;
using CareWell.DataViews.Salud;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Queries.Salud;
using CareWell.Repository;
using CareWell.Repository.Salud;
using CareWell.Security;

namespace CareWell.BusinessService.Salud
{
    public class AdministrarEventoSaludBusinessService : BusinessService, IAdministrarEventoSaludBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IEventoSaludRepository EventoSaludRepository { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }
        private IBaseFactory Factory { get; set; }

        public AdministrarEventoSaludBusinessService(IUnitOfWork unitOfWork,
                                                     IUserContext userContext,
                                                     IEventoSaludRepository eventoSaludRepository,
                                                     IEntityLoaderDomainService entityLoaderDomainService,
                                                     IValidadorPermisoAccion validadorPermisoAccion,
                                                     IBaseFactory baseFactory)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.EventoSaludRepository = eventoSaludRepository;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
            this.Factory = baseFactory;
        }

        public List<EventoSaludDataView> ObtenerTodos(EventoSaludQuery query)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var persona = this.EntityLoaderDomainService.GetByID<Persona>(query.PersonaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(persona, usuario.Persona);

            return this.EventoSaludRepository.ObtenerTodos(query);
        }

        public void Crear(CrearEventoSaludCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);

            var crearEventoSalud = new CrearEventoSalud(
                Persona: this.EntityLoaderDomainService.GetByID<Persona>(command.PersonaID),
                Colaborador: usuario.Persona,
                Tipo: this.EntityLoaderDomainService.GetByID<TipoEvento>(command.TipoID),
                FechaHora: command.FechaHora,
                Descripcion: command.Descripcion
            );

            var eventoSalud = this.Factory.Crear<EventoSalud>();

            eventoSalud.Crear(crearEventoSalud,
                              this.ValidadorPermisoAccion);

            this.EventoSaludRepository.Add(eventoSalud);

            this.UnitOfWork.SaveChanges();
        }

        public void Eliminar(int eventoSaludID)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var eventoSalud = this.EventoSaludRepository.GetByID(eventoSaludID);

            eventoSalud.Eliminar(usuario.Persona,
                                 this.ValidadorPermisoAccion);

            this.EventoSaludRepository.Remove(eventoSalud);

            this.UnitOfWork.SaveChanges();
        }

        public void AgregarNota(CrearNotaEventoSaludCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var eventoSalud = this.EventoSaludRepository.GetByID(command.EventoSaludID);

            var crearNota = new CrearNotaEventoSalud(
                Autor: usuario.Persona,
                Contenido: command.Contenido
            );

            eventoSalud.AgregarNota(crearNota,
                                    this.ValidadorPermisoAccion,
                                    this.Factory);

            this.UnitOfWork.SaveChanges();
        }

        public void ModificarNota(ModificarNotaEventoSaludCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var eventoSalud = this.EventoSaludRepository.GetByID(command.EventoSaludID);

            var modificarNota = new ModificarNotaEventoSalud(
                Colaborador: usuario.Persona,
                NotaID: command.NotaID,
                Contenido: command.Contenido
            );

            eventoSalud.ModificarNota(modificarNota,
                                      this.ValidadorPermisoAccion);

            this.UnitOfWork.SaveChanges();
        }

        public void EliminarNota(EliminarNotaEventoSaludCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var eventoSalud = this.EventoSaludRepository.GetByID(command.EventoSaludID);

            var eliminarNota = new EliminarNotaEventoSalud(
                Colaborador: usuario.Persona,
                NotaID: command.NotaID
            );

            eventoSalud.EliminarNota(eliminarNota,
                                     this.ValidadorPermisoAccion);

            this.UnitOfWork.SaveChanges();
        }
    }
}
