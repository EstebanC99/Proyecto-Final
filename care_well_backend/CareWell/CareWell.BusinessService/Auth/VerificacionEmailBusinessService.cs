using CareWell.BusinessService.Abstractions.Auth;
using CareWell.Commands.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.Factories;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Auth;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using CareWell.Global.Notificaciones;
using CareWell.Repository;
using CareWell.Repository.Auth;

namespace CareWell.BusinessService.Auth
{
    public class VerificacionEmailBusinessService : BusinessService, IVerificacionEmailBusinessService
    {
        private IUsuarioRepository UsuarioRepository { get; set; }
        private ICodigoVerificacionEmailRepository CodigoVerificacionEmailRepository { get; set; }
        private IBaseFactory Factory { get; set; }
        private IPasswordHasherDomainService PasswordHasherDomainService { get; set; }
        private IGeneradorCodigoOtpDomainService GeneradorCodigoOtpDomainService { get; set; }
        private IEnvioEmailBusinessService EnvioEmailBusinessService { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IValidadorLimiteEnvioEmail ValidadorLimiteEnvioEmail { get; set; }

        public VerificacionEmailBusinessService(IUnitOfWork unitOfWork,
                                                IUsuarioRepository usuarioRepository,
                                                ICodigoVerificacionEmailRepository codigoVerificacionEmailRepository,
                                                IBaseFactory baseFactory,
                                                IPasswordHasherDomainService passwordHasherDomainService,
                                                IGeneradorCodigoOtpDomainService generadorCodigoOtpDomainService,
                                                IEnvioEmailBusinessService envioEmailBusinessService,
                                                IEntityLoaderDomainService entityLoaderDomainService,
                                                IValidadorLimiteEnvioEmail validadorLimiteEnvioEmail)
            : base(unitOfWork)
        {
            this.UsuarioRepository = usuarioRepository;
            this.CodigoVerificacionEmailRepository = codigoVerificacionEmailRepository;
            this.Factory = baseFactory;
            this.PasswordHasherDomainService = passwordHasherDomainService;
            this.GeneradorCodigoOtpDomainService = generadorCodigoOtpDomainService;
            this.EnvioEmailBusinessService = envioEmailBusinessService;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.ValidadorLimiteEnvioEmail = validadorLimiteEnvioEmail;
        }

        public void EnviarCodigo(EnviarCodigoVerificacionEmailCommand command)
        {
            var usuario = this.UsuarioRepository.GetByEmail(command.Email);

            if (usuario is null) return;

            this.ValidadorLimiteEnvioEmail.ValidarCantidadEnviosUltimaHora(usuario);

            var codigoVigente = this.CodigoVerificacionEmailRepository.GetVigentePorUsuario(usuario.ID);

            if (codigoVigente is not null)
                codigoVigente.Consumir();

            var codigoGenerado = this.GeneradorCodigoOtpDomainService.Generar();

            var crearCodigo = new CrearCodigoVerificacionEmail(
                Usuario: usuario,
                CodigoHash: this.PasswordHasherDomainService.Hashear(codigoGenerado),
                Expiracion: DateTime.Now.AddMinutes(ParametrosVerificacionEmail.MinutosExpiracion)
            );

            var codigoVerificacionEmail = this.Factory.Crear<CodigoVerificacionEmail>();
            codigoVerificacionEmail.Crear(crearCodigo);

            this.CodigoVerificacionEmailRepository.Add(codigoVerificacionEmail);

            this.UnitOfWork.SaveChanges();

            this.EnvioEmailBusinessService.Enviar(new EnviarEmailCommand
            {
                Destinatario = usuario.NombreUsuario,
                NombreDestinatario = usuario.Persona.Nombre,
                Asunto = Emails.AsuntoCodigoVerificacionCareWell,
                CuerpoHtml = Emails.CodigoVerificacionEmailFormat(codigoGenerado, ParametrosVerificacionEmail.MinutosExpiracion.ToString())
            });
        }

        public void Verificar(VerificarEmailCommand command)
        {
            var usuario = this.UsuarioRepository.GetByEmail(command.Email);

            if (usuario is null)
                throw new ValidacionDominioException(Mensajes.CodigoVerificacionEmailInvalido);

            var codigo = this.CodigoVerificacionEmailRepository.GetVigentePorUsuario(usuario.ID);

            if (codigo is null)
                throw new ValidacionDominioException(Mensajes.CodigoVerificacionEmailInvalido);

            try
            {
                codigo.Verificar(command.Codigo, this.PasswordHasherDomainService);
            }
            catch
            {
                this.UnitOfWork.SaveChanges();
                throw;
            }

            usuario.ConfirmarEmail(this.EntityLoaderDomainService);

            this.UnitOfWork.SaveChanges();
        }
    }
}
