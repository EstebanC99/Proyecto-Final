namespace CareWell.Security
{
    public interface IUserContext
    {
        int UsuarioID { get; }
        bool HayUsuario { get; }
    }
}
