namespace CareWell.DataViews.Auth
{
    public class LoginDataView
    {
        public string AccessToken { get; set; }

        public DateTime Expiracion { get; set; }

        public string RefreshToken { get; set; }

        public UsuarioDataView Usuario { get; set; }
    }
}
