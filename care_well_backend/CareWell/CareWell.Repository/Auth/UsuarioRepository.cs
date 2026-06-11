using CareWell.Domain.Auth;

namespace CareWell.Repository.Auth
{
    public class UsuarioRepository : Repository<Usuario>, IUsuarioRepository
    {
        public UsuarioRepository(CareWellDbContext dbContext) : base(dbContext)
        {
        }

        public Usuario GetByEmail(string email)
        {
            return this.DbSet.FirstOrDefault(u => u.NombreUsuario == email);
        }
    }
}
