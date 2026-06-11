using CareWell.Domain;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository
{
    public abstract class Repository<TBaseEntity> : IRepository<TBaseEntity>
        where TBaseEntity : BaseEntity
    {
        protected CareWellDbContext DbContext { get; set; }
        protected DbSet<TBaseEntity> DbSet { get; set; }

        protected Repository(CareWellDbContext dbContext)
        {
            this.DbContext = dbContext;
            this.DbSet = dbContext.Set<TBaseEntity>();
        }

        public virtual void Add(TBaseEntity entity)
        {
            this.DbSet.Add(entity);
        }

        public virtual void Remove(TBaseEntity entity)
        {
            this.DbSet.Remove(entity);
        }

        public virtual TBaseEntity GetByID(int id)
        {
            return this.DbSet.FirstOrDefault(e => e.ID == id);
        }
    }
}
