using CareWell.Domain;

namespace CareWell.Repository
{
    public interface IEntityLoaderRepository
    {
        TBaseEntity GetByID<TBaseEntity>(int ID) where TBaseEntity : BaseEntity;
        IQueryable<TBaseEntity> Query<TBaseEntity>() where TBaseEntity : BaseEntity;
    }
}