namespace CareWell.DataViews.Auth
{
    public class LoginDataView
    {
        public string AccessToken { get; set; }

        public DateTime Expiracion { get; set; }

        public int UsuarioID { get; set; }

        public string Email { get; set; }

        public string RefreshToken { get; set; }
    }
}
