using CareWell.BusinessService.Abstractions.Auth;
using CareWell.Commands.Auth;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Enumeraciones.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using CareWell.Global.Notificaciones;
using CareWell.Repository;
using CareWell.Repository.Auth;

namespace CareWell.BusinessService.Auth
{
    public class RecuperacionContrasenaBusinessService : BusinessService, IRecuperacionContrasenaBusinessService
    {
        private IUsuarioRepository UsuarioRepository { get; set; }
        private IGestorCodigoVerificacionDomainService GestorCodigoVerificacionDomainService { get; set; }
        private IEnvioEmailBusinessService EnvioEmailBusinessService { get; set; }
        private IRefreshTokenRepository RefreshTokenRepository { get; set; }
        private IPasswordHasherDomainService PasswordHasherDomainService { get; set; }

        public RecuperacionContrasenaBusinessService(IUnitOfWork unitOfWork,
                                                     IUsuarioRepository usuarioRepository,
                                                     IGestorCodigoVerificacionDomainService gestorCodigoVerificacionDomainService,
                                                     IEnvioEmailBusinessService envioEmailBusinessService,
                                                     IRefreshTokenRepository refreshTokenRepository,
                                                     IPasswordHasherDomainService passwordHasherDomainService)
            : base(unitOfWork)
        {
            this.UsuarioRepository = usuarioRepository;
            this.GestorCodigoVerificacionDomainService = gestorCodigoVerificacionDomainService;
            this.EnvioEmailBusinessService = envioEmailBusinessService;
            this.RefreshTokenRepository = refreshTokenRepository;
            this.PasswordHasherDomainService = passwordHasherDomainService;
        }

        public void SolicitarReset(SolicitarResetContrasenaCommand command)
        {
            var usuario = this.UsuarioRepository.GetByEmail(command.Email);

            if (usuario is null) return;

            usuario.ValidarHabilitadoParaRecuperarContrasena();

            var codigoGenerado = this.GestorCodigoVerificacionDomainService.EmitirCodigo(usuario, TipoCodigoVerificacionEnum.RecuperacionContrasena);

            this.EnvioEmailBusinessService.Enviar(new EnviarEmailCommand
            {
                Destinatario = usuario.NombreUsuario,
                NombreDestinatario = usuario.Persona.Nombre,
                Asunto = Emails.AsuntoRestablecerContrasenaCareWell,
                CuerpoHtml = Emails.RecuperacionContrasenaFormat(codigoGenerado, ParametrosVerificacionCodigo.MinutosExpiracion.ToString())
            });
        }

        public void ConfirmarReset(ConfirmarResetContrasenaCommand command)
        {
            var usuario = this.UsuarioRepository.GetByEmail(command.Email);

            if (usuario is null)
                throw new ValidacionDominioException(Mensajes.CodigoVerificacionInvalido);

            this.GestorCodigoVerificacionDomainService.ValidarYConsumir(usuario, TipoCodigoVerificacionEnum.RecuperacionContrasena, command.Codigo);

            usuario.RestablecerContrasena(command.ContrasenaNueva, this.PasswordHasherDomainService);

            foreach (var refreshToken in this.RefreshTokenRepository.GetVigentesPorUsuario(usuario))
                refreshToken.Revocar();

            this.UnitOfWork.SaveChanges();
        }
    }
}
