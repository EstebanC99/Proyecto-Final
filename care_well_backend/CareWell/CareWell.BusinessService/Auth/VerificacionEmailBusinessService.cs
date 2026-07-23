using CareWell.BusinessService.Abstractions.Auth;
using CareWell.Commands.Auth;
using CareWell.Domain.DomainServices;
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
    public class VerificacionEmailBusinessService : BusinessService, IVerificacionEmailBusinessService
    {
        private IUsuarioRepository UsuarioRepository { get; set; }
        private IGestorCodigoVerificacionDomainService GestorCodigoVerificacionDomainService { get; set; }
        private IEnvioEmailBusinessService EnvioEmailBusinessService { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }

        public VerificacionEmailBusinessService(IUnitOfWork unitOfWork,
                                                IUsuarioRepository usuarioRepository,
                                                IGestorCodigoVerificacionDomainService gestorCodigoVerificacionDomainService,
                                                IEnvioEmailBusinessService envioEmailBusinessService,
                                                IEntityLoaderDomainService entityLoaderDomainService)
            : base(unitOfWork)
        {
            this.UsuarioRepository = usuarioRepository;
            this.GestorCodigoVerificacionDomainService = gestorCodigoVerificacionDomainService;
            this.EnvioEmailBusinessService = envioEmailBusinessService;
            this.EntityLoaderDomainService = entityLoaderDomainService;
        }

        public void EnviarCodigo(EnviarCodigoVerificacionCommand command)
        {
            var usuario = this.UsuarioRepository.GetByEmail(command.Email);

            if (usuario is null) return;

            var codigoGenerado = this.GestorCodigoVerificacionDomainService.EmitirCodigo(usuario, TipoCodigoVerificacionEnum.VerificacionEmail);

            this.EnvioEmailBusinessService.Enviar(new EnviarEmailCommand
            {
                Destinatario = usuario.NombreUsuario,
                NombreDestinatario = usuario.Persona.Nombre,
                Asunto = Emails.AsuntoCodigoVerificacionCareWell,
                CuerpoHtml = Emails.CodigoVerificacionFormat(codigoGenerado, ParametrosVerificacionCodigo.MinutosExpiracion.ToString())
            });
        }

        public void Verificar(VerificarEmailCommand command)
        {
            var usuario = this.UsuarioRepository.GetByEmail(command.Email);

            if (usuario is null)
                throw new ValidacionDominioException(Mensajes.CodigoVerificacionInvalido);

            this.GestorCodigoVerificacionDomainService.ValidarYConsumir(usuario, TipoCodigoVerificacionEnum.VerificacionEmail, command.Codigo);

            usuario.ConfirmarEmail(this.EntityLoaderDomainService);

            this.UnitOfWork.SaveChanges();
        }
    }
}
