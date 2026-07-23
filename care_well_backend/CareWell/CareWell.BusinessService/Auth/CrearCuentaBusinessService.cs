using CareWell.BusinessService.Abstractions.Auth;
using CareWell.BusinessService.Helpers;
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
using Microsoft.Extensions.Logging;

namespace CareWell.BusinessService.Auth
{
    public class CrearCuentaBusinessService : BusinessService, ICrearCuentaBusinessService
    {
        private IPersonaRepository PersonaRepository { get; set; }
        private IUsuarioRepository UsuarioRepository { get; set; }
        private IBaseFactory Factory { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IPasswordHasherDomainService PasswordHasherDomainService { get; set; }
        private IVerificacionEmailBusinessService VerificacionEmailBusinessService { get; set; }
        private ILogger<CrearCuentaBusinessService> Logger { get; set; }

        public CrearCuentaBusinessService(IUnitOfWork unitOfWork,
                                          IPersonaRepository personaRepository,
                                          IUsuarioRepository usuarioRepository,
                                          IBaseFactory baseFactory,
                                          IEntityLoaderDomainService entityLoaderDomainService,
                                          IPasswordHasherDomainService passwordHasherDomainService,
                                          IVerificacionEmailBusinessService verificacionEmailBusinessService,
                                          ILogger<CrearCuentaBusinessService> logger)
            : base(unitOfWork)
        {
            this.PersonaRepository = personaRepository;
            this.UsuarioRepository = usuarioRepository;
            this.Factory = baseFactory;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.PasswordHasherDomainService = passwordHasherDomainService;
            this.VerificacionEmailBusinessService = verificacionEmailBusinessService;
            this.Logger = logger;
        }

        public void Crear(CrearCuentaCommand command)
        {
            var crearPersona = new CrearModificarPersona(
                Nombre: command.Nombre,
                Apellido: command.Apellido,
                Documento: command.Documento,
                FechaNacimiento: command.FechaNacimiento,
                Telefono: command.Telefono,
                Imagen: ImageProcessorHelper.GetImage(command.Imagen),
                Email: command.Email
            );

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

            try
            {
                this.VerificacionEmailBusinessService.EnviarCodigo(new EnviarCodigoVerificacionCommand { Email = command.Email, });
            }
            catch (Exception ex)
            {
                this.Logger.LogError(ex, "No se pudo enviar el código de verificación al crear la cuenta {Email}", command.Email);
            }
        }
    }
}
