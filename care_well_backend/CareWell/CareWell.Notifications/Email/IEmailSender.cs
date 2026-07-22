namespace CareWell.Notifications.Email
{
    public interface IEmailSender
    {
        bool Enviar(string destinatario, string nombre, string asunto, string cuerpoHtml);
    }
}