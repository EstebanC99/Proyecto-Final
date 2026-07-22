using CareWell.BusinessService.Abstractions.Auth;
using CareWell.Commands.Auth;
using CareWell.Global.Mensajes;
using CareWell.Notifications.Email;

namespace CareWell.BusinessService.Auth
{
    public class EnvioEmailBusinessService : IEnvioEmailBusinessService
    {
        private IEmailSender EmailSender { get; set; }

        public EnvioEmailBusinessService(IEmailSender emailSender)
        {
            this.EmailSender = emailSender;
        }

        public void Enviar(EnviarEmailCommand command)
        {
            var respuesta = this.EmailSender.Enviar(command.Destinatario, command.NombreDestinatario, command.Asunto, command.CuerpoHtml);

            if (respuesta)
                return;

            throw new Exception(Mensajes.ErrorAlEnviarEmailPorFavorReintente);
        }
    }
}
