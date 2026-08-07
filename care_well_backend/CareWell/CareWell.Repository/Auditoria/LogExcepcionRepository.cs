using CareWell.Domain.Auditoria;

namespace CareWell.Repository.Auditoria
{
    public class LogExcepcionRepository : ILogExcepcionRepository
    {
        private LogDbContext DbContext { get; set; }

        public LogExcepcionRepository(LogDbContext dbContext)
        {
            this.DbContext = dbContext;
        }

        public void Add(LogExcepcion logExcepcion)
        {
            this.DbContext.Set<LogExcepcion>().Add(logExcepcion);
        }
    }
}
