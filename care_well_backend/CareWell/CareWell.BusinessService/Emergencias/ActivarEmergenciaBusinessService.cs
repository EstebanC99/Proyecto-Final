using CareWell.BusinessService.Abstractions.Emergencias;
using CareWell.Commands.Emergencias;
using CareWell.DataViews.Emergencias;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Emergencias;
using CareWell.Domain.Emergencias;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.General;
using CareWell.Queries.Emergencias;
using CareWell.Repository;
using CareWell.Repository.Emergencias;
using CareWell.Security;

namespace CareWell.BusinessService.Emergencias
{
    public class ActivarEmergenciaBusinessService : BusinessService, IActivarEmergenciaBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IBaseFactory Factory { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }
        private IEmergenciaRepository EmergenciaRepository { get; set; }
        private INotificarEmergenciaDomainService NotificarEmergenciaDomainService { get; set; }

        public ActivarEmergenciaBusinessService(IUnitOfWork unitOfWork,
                                                IUserContext userContext,
                                                IEntityLoaderDomainService entityLoaderDomainService,
                                                IBaseFactory baseFactory,
                                                IValidadorPermisoAccion validadorPermisoAccion,
                                                IEmergenciaRepository emergenciaRepository,
                                                INotificarEmergenciaDomainService notificarEmergenciaDomainService)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.Factory = baseFactory;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
            this.EmergenciaRepository = emergenciaRepository;
            this.NotificarEmergenciaDomainService = notificarEmergenciaDomainService;
        }

        public List<EmergenciaDataView> Obtener(ObtenerEmergenciasQuery query)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var persona = this.EntityLoaderDomainService.GetByID<Persona>(query.PersonaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(persona, usuario.Persona);

            return this.EmergenciaRepository.ObtenerPorPersona(query);
        }

        public async Task Activar(ActivarEmergenciaCommand command, CancellationToken cancellationToken)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var persona = this.EntityLoaderDomainService.GetByID<Persona>(command.PersonaID);

            var emergencia = this.Factory.Crear<Emergencia>();

            emergencia.Activar(new ActivarEmergencia(
                Persona: persona,
                Activador: usuario.Persona,
                Descripcion: command.Descripcion
            ), this.ValidadorPermisoAccion);

            this.EmergenciaRepository.Add(emergencia);

            this.UnitOfWork.SaveChanges();

            try
            {
                await this.NotificarEmergenciaDomainService.Notificar(emergencia, cancellationToken);

                this.UnitOfWork.SaveChanges();
            }
            catch { }
        }
    }
}
