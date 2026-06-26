using CareWell.BusinessService.Abstractions.EquipoCuidado;
using CareWell.Commands.EquipoCuidado;
using CareWell.DataViews.EquipoCuidado;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.EquipoCuidado;
using CareWell.Repository;
using CareWell.Repository.EquipoCuidado;
using CareWell.Repository.General;
using CareWell.Security;

namespace CareWell.BusinessService.EquipoCuidado
{
    public class AdministrarPersonasCargoBusinessService : BusinessService, IAdministrarPersonasCargoBusinessService
    {
        private IBaseFactory Factory { get; set; }
        private IUserContext UserContext { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IPersonaRepository PersonaRepository { get; set; }
        private IAsignacionCuidadoRepository AsignacionCuidadoRepository { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }

        public AdministrarPersonasCargoBusinessService(IUnitOfWork unitOfWork,
                                                       IBaseFactory baseFactory,
                                                       IUserContext userContext,
                                                       IEntityLoaderDomainService entityLoaderDomainService,
                                                       IPersonaRepository personaRepository,
                                                       IAsignacionCuidadoRepository asignacionCuidadoRepository,
                                                       IValidadorPermisoAccion validadorPermisoAccion)
            : base(unitOfWork)
        {
            this.Factory = baseFactory;
            this.UserContext = userContext;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.PersonaRepository = personaRepository;
            this.AsignacionCuidadoRepository = asignacionCuidadoRepository;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
        }

        public List<AsignacionCuidadoDataView> ObtenerAsignacionesUsuarioLogueado()
        {
            var usuarioID = this.UserContext.UsuarioID;

            return this.AsignacionCuidadoRepository.ObtenerAsignacionesPorUsuario(usuarioID);
        }

        public void CrearPersonaCargo(CrearPersonaCargoCommand command)
        {
            var usuarioLogueado = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);

            var personaCargo = this.Factory.Crear<Persona>();
            personaCargo.CrearModificar(new Domain.ValueObjects.General.CrearModificarPersona(
                command.Nombre,
                command.Apellido,
                command.Documento,
                command.FechaNacimiento,
                command.Email,
                command.Telefono
            ));
            this.PersonaRepository.Add(personaCargo);

            var crearAsignacionResponsable = new CrearAsignacionResponsable(
                personaCargo,
                usuarioLogueado
            );

            var asignacionCuidado = this.Factory.Crear<AsignacionCuidado>();

            asignacionCuidado.AsignarResponsable(crearAsignacionResponsable,
                                                 this.EntityLoaderDomainService);

            this.AsignacionCuidadoRepository.Add(asignacionCuidado);

            this.UnitOfWork.SaveChanges();
        }

        public void ModificarPersonaCargo(ModificarPersonaCargoCommand command)
        {
            var asignacionCuidado = this.AsignacionCuidadoRepository.GetByID(command.AsignacionCuidadoID);

            var modificarAsignacionResponsable = new ModificarInformacionPersona(
                command.Nombre,
                command.Apellido,
                command.Documento,
                command.FechaNacimiento,
                command.Email,
                command.Telefono,
                this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID));

            asignacionCuidado.ModificarInformacionPersona(modificarAsignacionResponsable,
                                                          this.ValidadorPermisoAccion);

            this.UnitOfWork.SaveChanges();
        }

        public void EliminarAsignacion(int asignacionCuidadoID)
        {
            var asignacionCuidado = this.AsignacionCuidadoRepository.GetByID(asignacionCuidadoID);

            asignacionCuidado.Eliminar(this.EntityLoaderDomainService);

            this.UnitOfWork.SaveChanges();
        }

        public void ReactivarAsignacion(int asignacionCuidadoID)
        {
            var asignacionCuidado = this.AsignacionCuidadoRepository.GetByID(asignacionCuidadoID);

            asignacionCuidado.Reactivar(this.EntityLoaderDomainService);

            this.UnitOfWork.SaveChanges();
        }
    }
}
