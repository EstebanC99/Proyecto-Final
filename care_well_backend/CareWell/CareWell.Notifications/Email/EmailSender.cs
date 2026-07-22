using Microsoft.Extensions.Options;
using System.Net;
using System.Net.Mail;

namespace CareWell.Notifications.Email
{
    public class EmailSender : IEmailSender
    {
        private EmailOptions EmailOptions { get; set; }

        public EmailSender(IOptions<EmailOptions> options)
        {
            this.EmailOptions = options.Value;
        }

        public bool Enviar(string destinatario, string nombre, string asunto, string cuerpoHtml)
        {
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
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ElasticEmail] Error al enviar email a '{destinatario}': {ex}");
                return false;
            }
        }
    }
}
