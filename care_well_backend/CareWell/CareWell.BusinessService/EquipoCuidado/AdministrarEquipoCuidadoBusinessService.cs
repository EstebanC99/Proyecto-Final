using CareWell.BusinessService.Abstractions.EquipoCuidado;
using CareWell.Commands.EquipoCuidado;
using CareWell.DataViews.EquipoCuidado;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.Factories;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.EquipoCuidado;
using CareWell.Queries.EquipoCuidado;
using CareWell.Repository;
using CareWell.Repository.EquipoCuidado;
using CareWell.Repository.General;
using CareWell.Security;

namespace CareWell.BusinessService.EquipoCuidado
{
    public class AdministrarEquipoCuidadoBusinessService : BusinessService, IAdministrarEquipoCuidadoBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }
        private IPersonaRepository PersonaRepository { get; set; }
        private IBaseFactory Factory { get; set; }
        private IAsignacionCuidadoRepository AsignacionCuidadoRepository { get; set; }

        public AdministrarEquipoCuidadoBusinessService(IUnitOfWork unitOfWork,
                                                       IUserContext userContext,
                                                       IEntityLoaderDomainService entityLoaderDomainService,
                                                       IValidadorPermisoAccion validadorPermisoAccion,
                                                       IPersonaRepository personaRepository,
                                                       IBaseFactory baseFactory,
                                                       IAsignacionCuidadoRepository asignacionCuidadoRepository)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
            this.PersonaRepository = personaRepository;
            this.Factory = baseFactory;
            this.AsignacionCuidadoRepository = asignacionCuidadoRepository;
        }

        public List<AsignacionCuidadoDataView> ObtenerAsignacionesPorPersonaCuidada(AsignacionCuidadoQuery query)
        {
            return this.AsignacionCuidadoRepository.ObtenerAsignacionesPorPersonaCuidada(query.PersonaCuidadaID);
        }

        public void Asignar(CrearAsignacionCuidadoCommand command)
        {
            var usuarioAsignador = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);

            var personaCuidada = this.PersonaRepository.GetByID(command.PersonaCuidadaID);
            var colaborador = this.PersonaRepository.GetByEmail(command.ColaboradorEmail);
            var rolCuidado = this.EntityLoaderDomainService.GetByID<RolCuidado>(command.RolCuidadoID);
            var permisosCuidado = command.PermisosIDs.Select(p => this.EntityLoaderDomainService.GetByID<PermisoCuidado>(p)).ToList();

            var crearAsignacion = new CrearAsignacion(
                PersonaCuidada: personaCuidada,
                Colaborador: colaborador,
                Asignador: usuarioAsignador.Persona,
                Rol: rolCuidado,
                Permisos: permisosCuidado
            );

            var asignacionCuidado = this.Factory.Crear<AsignacionCuidado>();

            asignacionCuidado.Asignar(crearAsignacion,
                                      this.EntityLoaderDomainService,
                                      this.ValidadorPermisoAccion);

            this.AsignacionCuidadoRepository.Add(asignacionCuidado);

            this.UnitOfWork.SaveChanges();
        }

        public void ModificarPermisos(ModificarPermisosAsignacionCommand command)
        {
            var usuarioAsignador = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);

            var modificarPermisos = new ModificarPermisosAsignacion(
                Asignador: usuarioAsignador.Persona,
                NuevosPermisos: command.PermisosIDs.Select(p => this.EntityLoaderDomainService.GetByID<PermisoCuidado>(p)).ToList()
            );

            var asignacionCuidado = this.AsignacionCuidadoRepository.GetByID(command.AsignacionCuidadoID);

            asignacionCuidado.ModificarPermisos(modificarPermisos,
                                                this.ValidadorPermisoAccion);

            this.UnitOfWork.SaveChanges();
        }
    }
}
