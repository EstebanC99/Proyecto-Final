using CareWell.Repository.Config.Auditoria;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository
{
    public class LogDbContext : DbContext
    {
        public LogDbContext(DbContextOptions<LogDbContext> options) : base(options) { }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.ApplyConfiguration(new LogExcepcionConfig());
            modelBuilder.ApplyConfiguration(new LogServicioExternoConfig());
        }
    }
}
