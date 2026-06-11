namespace CareWell.Domain.DomainServices
{
    public interface IEntityLoaderDomainService
    {
        TBaseEntity GetByID<TBaseEntity>(int id) where TBaseEntity : BaseEntity;
    }
}
