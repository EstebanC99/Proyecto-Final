using CareWell.Logger;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Net;
using System.Net.Mail;

namespace CareWell.Notifications.Email
{
    public class EmailSender : IEmailSender
    {
        private EmailOptions EmailOptions { get; set; }
        private ILogger<EmailSender> Logger { get; set; }
        private IRegistradorLogServicioExterno RegistradorLogServicioExterno { get; set; }

        public EmailSender(IOptions<EmailOptions> options,
                           ILogger<EmailSender> logger,
                           IRegistradorLogServicioExterno registradorLogServicioExterno)
        {
            this.EmailOptions = options.Value;
            this.Logger = logger;
            this.RegistradorLogServicioExterno = registradorLogServicioExterno;
        }

        public bool Enviar(string destinatario, string nombre, string asunto, string cuerpoHtml)
        {
            var request = $"To: {destinatario} <{nombre}>; Subject: {asunto}; Body: {cuerpoHtml}";

            try
            {
                using var mensaje = new MailMessage();
                mensaje.From = new MailAddress(this.EmailOptions.RemitenteEmail, this.EmailOptions.RemitenteNombre);
                mensaje.To.Add(new MailAddress(destinatario, nombre));
                mensaje.Subject = asunto;
                mensaje.Body = cuerpoHtml;
                mensaje.IsBodyHtml = true;

                using var cliente = new SmtpClient(this.EmailOptions.Host, this.EmailOptions.Puerto);
                cliente.EnableSsl = this.EmailOptions.UsarSsl;
                cliente.DeliveryMethod = SmtpDeliveryMethod.Network;
                cliente.Credentials = new NetworkCredential(this.EmailOptions.Usuario, this.EmailOptions.Password);

                cliente.Send(mensaje);

                this.RegistradorLogServicioExterno.Registrar("SMTP", request, "Enviado correctamente.");
                return true;
            }
            catch (Exception ex)
            {
                this.RegistradorLogServicioExterno.Registrar("SMTP", request, ex.ToString());
                this.Logger.LogError(ex, "Error al enviar email a '{Destinatario}'.", destinatario);
                return false;
            }
        }
    }
}
