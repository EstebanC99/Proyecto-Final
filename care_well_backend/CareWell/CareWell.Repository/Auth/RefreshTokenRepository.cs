using CareWell.Domain.Auth;

namespace CareWell.Repository.Auth
{
    public class RefreshTokenRepository : Repository<RefreshToken>, IRefreshTokenRepository
    {
        public RefreshTokenRepository(CareWellDbContext dbContext) : base(dbContext)
        {
        }

        public RefreshToken GetByToken(string token)
        {
            return this.DbSet.FirstOrDefault(t => t.Token == token);
        }
    }
}
