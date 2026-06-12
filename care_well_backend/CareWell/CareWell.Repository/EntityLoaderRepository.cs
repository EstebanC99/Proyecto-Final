using CareWell.Domain;

namespace CareWell.Repository
{
    public class EntityLoaderRepository : IEntityLoaderRepository
    {
        protected CareWellDbContext DbContext { get; set; }

        public EntityLoaderRepository(CareWellDbContext dbContext)
        {
            this.DbContext = dbContext;
        }

        public TBaseEntity GetByID<TBaseEntity>(int ID) where TBaseEntity : BaseEntity
        {
            return this.DbContext.Set<TBaseEntity>().Find(ID);
        }

        public IQueryable<TBaseEntity> Query<TBaseEntity>() where TBaseEntity : BaseEntity
        {
            return this.DbContext.Set<TBaseEntity>().AsQueryable();
        }
    }
}
