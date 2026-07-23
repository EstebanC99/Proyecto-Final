using CareWell.Domain.Auth;
using CareWell.Global.Enumeraciones.Auth;

namespace CareWell.Repository.Auth
{
    public class CodigoVerificacionRepository : Repository<CodigoVerificacion>, ICodigoVerificacionRepository
    {
        public CodigoVerificacionRepository(CareWellDbContext dbContext) : base(dbContext) { }

        public CodigoVerificacion? GetVigentePorUsuario(Usuario usuario, TipoCodigoVerificacionEnum tipo)
        {
            return this.DbSet
                .Where(c => c.Usuario.ID == usuario.ID
                         && c.Tipo == tipo
                         && !c.Consumido
                         && c.Expiracion > DateTime.Now)
                .OrderByDescending(c => c.FechaCreacion)
                .FirstOrDefault();
        }
    }
}
