using CareWell.Domain.Auth;

namespace CareWell.Repository.Auth
{
    public interface IRefreshTokenRepository : IRepository<RefreshToken>
    {
        RefreshToken GetByToken(string token);
        List<RefreshToken> GetVigentesPorUsuario(Usuario usuario);
    }
}