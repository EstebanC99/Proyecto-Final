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
    public class AdministrarPersonaEstadoAnimoBusinessService : BusinessService, IAdministrarPersonaEstadoAnimoBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IBaseFactory Factory { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }
        private IPersonaEstadoAnimoRepository PersonaEstadoAnimoRepository { get; set; }

        public AdministrarPersonaEstadoAnimoBusinessService(IUnitOfWork unitOfWork,
                                                            IUserContext userContext,
                                                            IEntityLoaderDomainService entityLoaderDomainService,
                                                            IBaseFactory baseFactory,
                                                            IValidadorPermisoAccion validadorPermisoAccion,
                                                            IPersonaEstadoAnimoRepository personaEstadoAnimoRepository)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.Factory = baseFactory;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
            this.PersonaEstadoAnimoRepository = personaEstadoAnimoRepository;
        }

        public PersonaEstadoAnimoDataView ObtenerAnimoHoy(PersonaEstadoAnimoHoyQuery query)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var persona = this.EntityLoaderDomainService.GetByID<Persona>(query.PersonaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(persona, usuario.Persona);

            return this.PersonaEstadoAnimoRepository.ObtenerAnimoHoy(query);
        }

        public List<PersonaEstadoAnimoDataView> ObtenerPorFechas(PersonaEstadoAnimoPorFechaQuery query)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var persona = this.EntityLoaderDomainService.GetByID<Persona>(query.PersonaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(persona, usuario.Persona);

            return this.PersonaEstadoAnimoRepository.ObtenerPorFechas(query);
        }

        public void Registrar(RegistrarEstadoAnimoCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);

            var registrarEstadoAnimo = new RegistrarEstadoAnimo(
                Persona: this.EntityLoaderDomainService.GetByID<Persona>(command.PersonaID),
                Colaborador: usuario.Persona,
                EstadoAnimo: this.EntityLoaderDomainService.GetByID<EstadoAnimo>(command.EstadoAnimoID),
                Observaciones: command.Observaciones
            );

            var personaEstadoAnimo = this.Factory.Crear<PersonaEstadoAnimo>();

            personaEstadoAnimo.Registrar(registrarEstadoAnimo,
                                         this.ValidadorPermisoAccion);

            this.PersonaEstadoAnimoRepository.Add(personaEstadoAnimo);

            this.UnitOfWork.SaveChanges();
        }
    }
}
