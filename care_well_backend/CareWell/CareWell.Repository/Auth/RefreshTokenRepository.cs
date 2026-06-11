using CareWell.Domain.Auth;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Auth
{
    public class RefreshTokenRepository : Repository<RefreshToken>, IRefreshTokenRepository
    {
        public RefreshTokenRepository(CareWellDbContext dbContext) : base(dbContext)
        {
        }

        public RefreshToken GetByToken(string token)
        {
            return this.DbSet.Include(t => t.Usuario).FirstOrDefault(t => t.Token == token);
        }
    }
}
