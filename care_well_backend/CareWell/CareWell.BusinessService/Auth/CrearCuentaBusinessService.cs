using CareWell.BusinessService.Abstractions.Auth;
using CareWell.Commands.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.ValueObjects.General;
using CareWell.Repository;
using CareWell.Repository.Auth;
using CareWell.Repository.General;

namespace CareWell.BusinessService.Auth
{
    public class CrearCuentaBusinessService : BusinessService, ICrearCuentaBusinessService
    {
        private IPersonaRepository PersonaRepository { get; set; }
        private IUsuarioRepository UsuarioRepository { get; set; }
        private IBaseFactory Factory { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IPasswordHasherDomainService PasswordHasherDomainService { get; set; }

        public CrearCuentaBusinessService(IUnitOfWork unitOfWork,
                                          IPersonaRepository personaRepository,
                                          IUsuarioRepository usuarioRepository,
                                          IBaseFactory baseFactory,
                                          IEntityLoaderDomainService entityLoaderDomainService,
                                          IPasswordHasherDomainService passwordHasherDomainService)
            : base(unitOfWork)
        {
            this.PersonaRepository = personaRepository;
            this.UsuarioRepository = usuarioRepository;
            this.Factory = baseFactory;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.PasswordHasherDomainService = passwordHasherDomainService;
        }

        public void Crear(CrearCuentaCommand command)
        {
            var crearPersona = new CrearModificarPersona(command.Nombre,
                                                command.Apellido,
                                                command.Documento,
                                                command.FechaNacimiento,
                                                command.Email,
                                                command.Telefono);

            var persona = this.Factory.Crear<Persona>();

            persona.CrearModificar(crearPersona);

            this.PersonaRepository.Add(persona);

            var usuario = this.Factory.Crear<Usuario>();

            usuario.Crear(persona,
                          command.Email,
                          command.Contrasena,
                          this.EntityLoaderDomainService,
                          this.PasswordHasherDomainService);

            this.UsuarioRepository.Add(usuario);

            this.UnitOfWork.SaveChanges();
        }
    }
}
