namespace CareWell.Repository.Auditoria
{
    public class LogUnitOfWork : ILogUnitOfWork
    {
        private LogDbContext DbContext { get; set; }

        public LogUnitOfWork(LogDbContext dbContext)
        {
            this.DbContext = dbContext;
        }

        public void SaveChanges()
        {
            this.DbContext.SaveChanges();
        }
    }
}
