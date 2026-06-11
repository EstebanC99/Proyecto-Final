namespace CareWell.DataViews.Auth
{
    public class AccessTokenDataView
    {
        public virtual string AccessToken { get; set; }

        public virtual string RefreshToken { get; set; }
    }
}
