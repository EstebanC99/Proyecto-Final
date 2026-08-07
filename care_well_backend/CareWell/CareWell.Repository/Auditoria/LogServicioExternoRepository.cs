using CareWell.Domain.Auditoria;

namespace CareWell.Repository.Auditoria
{
    public class LogServicioExternoRepository : ILogServicioExternoRepository
    {
        private LogDbContext DbContext { get; set; }

        public LogServicioExternoRepository(LogDbContext dbContext)
        {
            this.DbContext = dbContext;
        }

        public void Add(LogServicioExterno logServicioExterno)
        {
            this.DbContext.Set<LogServicioExterno>().Add(logServicioExterno);
        }
    }
}
