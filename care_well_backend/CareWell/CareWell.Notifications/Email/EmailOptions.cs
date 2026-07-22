namespace CareWell.Notifications.Email
{
    public class EmailOptions
    {
        public string Host { get; set; }
        public int Puerto { get; set; }
        public string Usuario { get; set; }
        public string Password { get; set; }
        public string RemitenteEmail { get; set; }
        public string RemitenteNombre { get; set; }
        public bool UsarSsl { get; set; }
    }
}
