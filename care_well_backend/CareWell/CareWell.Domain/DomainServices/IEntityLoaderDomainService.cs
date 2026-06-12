namespace CareWell.Domain.DomainServices
{
    public interface IEntityLoaderDomainService
    {
        TBaseEntity GetByID<TBaseEntity>(int id) where TBaseEntity : BaseEntity;
        IQueryable<TBaseEntity> Query<TBaseEntity>() where TBaseEntity : BaseEntity;
    }
}
