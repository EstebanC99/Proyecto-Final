namespace CareWell.Security
{
    public class UserContext : IUserContext, IUserContextWriter
    {
        public virtual int UsuarioID { get; set; }

        public virtual bool HayUsuario { get; set; }

        public void EstablecerUsuario(int usuarioID)
        {
            this.UsuarioID = usuarioID;
            this.HayUsuario = true;
        }
    }
}
