using CareWell.Domain.General;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository
{
    public class CareWellDbContext : DbContext
    {
        public CareWellDbContext(DbContextOptions<CareWellDbContext> options)
            : base(options)
        {
        }

        public DbSet<Persona> Personas => Set<Persona>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Aplica todas las IEntityTypeConfiguration<T> de este ensamblado
            // (carpeta Config). Cada entidad nueva queda configurada sola con
            // solo agregar su clase de configuración.
            modelBuilder.ApplyConfigurationsFromAssembly(typeof(CareWellDbContext).Assembly);
        }
    }
}
