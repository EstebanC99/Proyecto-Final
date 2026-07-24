using CareWell.BusinessService.Abstractions.Auth;
using CareWell.BusinessService.Helpers;
using CareWell.Commands.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.DomainServices.General;
using CareWell.Domain.Factories;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using CareWell.Repository;
using CareWell.Repository.Auth;
using CareWell.Repository.General;
using Microsoft.Extensions.Logging;

namespace CareWell.BusinessService.Auth
{
    public class CrearCredencialesBusinessService : BusinessService, ICrearCredencialesBusinessService
    {
        private IPersonaRepository PersonaRepository { get; set; }
        private IUsuarioRepository UsuarioRepository { get; set; }
        private IBaseFactory Factory { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IPasswordHasherDomainService PasswordHasherDomainService { get; set; }
        private IVerificacionEmailBusinessService VerificacionEmailBusinessService { get; set; }
        private IEvaluadorIdentidadPersonaDomainService EvaluadorIdentidadPersonaDomainService { get; set; }
        private ILogger<CrearCredencialesBusinessService> Logger { get; set; }

        public CrearCredencialesBusinessService(IUnitOfWork unitOfWork,
                                                IPersonaRepository personaRepository,
                                                IUsuarioRepository usuarioRepository,
                                                IBaseFactory baseFactory,
                                                IEntityLoaderDomainService entityLoaderDomainService,
                                                IPasswordHasherDomainService passwordHasherDomainService,
                                                IVerificacionEmailBusinessService verificacionEmailBusinessService,
                                                IEvaluadorIdentidadPersonaDomainService evaluadorIdentidadPersonaDomainService,
                                                ILogger<CrearCredencialesBusinessService> logger)
            : base(unitOfWork)
        {
            this.PersonaRepository = personaRepository;
            this.UsuarioRepository = usuarioRepository;
            this.Factory = baseFactory;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.PasswordHasherDomainService = passwordHasherDomainService;
            this.VerificacionEmailBusinessService = verificacionEmailBusinessService;
            this.EvaluadorIdentidadPersonaDomainService = evaluadorIdentidadPersonaDomainService;
            this.Logger = logger;
        }

        public void Crear(CrearCredencialesCommand command)
        {
            var persona = this.PersonaRepository.GetByEmail(command.Email);

            if (persona is null)
                throw new RecursoNoEncontradoException(Mensajes.NoExistePersonaConEseEmail);

            persona.ValidarCrearUsuario(this.EntityLoaderDomainService);

            var imagenDocumento = ImageProcessorHelper.GetImage(command.ImagenDocumento);

            if (!this.EvaluadorIdentidadPersonaDomainService.EsIdentidadCorrecta(persona, imagenDocumento))
                throw new ValidacionDominioException(Mensajes.IdentidadNoValidada);

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
                this.Logger.LogError(ex, "No se pudo enviar el código de verificación al crear las credenciales {Email}", command.Email);
            }
        }
    }
}
