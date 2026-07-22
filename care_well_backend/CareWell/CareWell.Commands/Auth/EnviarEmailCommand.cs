namespace CareWell.Commands.Auth
{
    public class EnviarEmailCommand
    {
        public string Destinatario { get; set; }
        public string NombreDestinatario { get; set; }
        public string Asunto { get; set; }
        public string CuerpoHtml { get; set; }
    }
}
