using CareWell.Domain.Auth;

namespace CareWell.Repository.Auth
{
    public class DispositivoUsuarioRepository : Repository<DispositivoUsuario>, IDispositivoUsuarioRepository
    {
        public DispositivoUsuarioRepository(CareWellDbContext dbContext) : base(dbContext) { }

        public DispositivoUsuario GetByToken(string token)
        {
            return this.DbSet.FirstOrDefault(d => d.Token == token);
        }

        public List<DispositivoUsuario> GetActivosPorUsuario(Usuario usuario)
        {
            return this.DbSet
               .Where(d => d.Usuario.ID == usuario.ID && d.Activo)
               .ToList();
        }

        public List<DispositivoUsuario> GetVigentesPorUsuario(Usuario usuario, DateTime fechaLimiteActividad)
        {
            return this.DbSet
                .Where(d => 
                    d.Usuario.ID == usuario.ID && 
                    d.Activo && 
                    d.FechaUltimoUso >= fechaLimiteActividad)
                .ToList();
        }

    }
}
