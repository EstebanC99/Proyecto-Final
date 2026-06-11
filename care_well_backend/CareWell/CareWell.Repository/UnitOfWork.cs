namespace CareWell.Repository
{
    public class UnitOfWork : IUnitOfWork
    {
        protected readonly CareWellDbContext dbContext;

        public UnitOfWork(CareWellDbContext dbContext)
        {
            this.dbContext = dbContext;
        }

        public void SaveChanges()
        {
            this.dbContext.SaveChanges();
        }
    }
}
