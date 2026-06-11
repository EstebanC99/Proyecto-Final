using CareWell.Domain.Auth;

namespace CareWell.Repository.Auth
{
    public interface IUsuarioRepository : IRepository<Usuario>
    {
        Usuario GetByEmail(string email);
    }
}