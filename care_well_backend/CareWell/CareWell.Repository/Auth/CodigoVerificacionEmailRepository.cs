using CareWell.Domain.Auth;

namespace CareWell.Repository.Auth
{
    public class CodigoVerificacionEmailRepository : Repository<CodigoVerificacionEmail>, ICodigoVerificacionEmailRepository
    {
        public CodigoVerificacionEmailRepository(CareWellDbContext dbContext) : base(dbContext) { }

        public CodigoVerificacionEmail? GetVigentePorUsuario(int usuarioID)
        {
            return this.DbSet
                .Where(c => c.Usuario.ID == usuarioID
                         && !c.Consumido
                         && c.Expiracion > DateTime.Now)
                .OrderByDescending(c => c.FechaCreacion)
                .FirstOrDefault();
        }
    }
}
