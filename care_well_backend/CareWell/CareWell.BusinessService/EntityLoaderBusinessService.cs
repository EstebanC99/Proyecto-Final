using CareWell.Domain;
using CareWell.Domain.DomainServices;
using CareWell.Repository;

namespace CareWell.BusinessService
{
    public class EntityLoaderBusinessService : IEntityLoaderDomainService
    {
        private IEntityLoaderRepository Repository { get; set; }

        public EntityLoaderBusinessService(IEntityLoaderRepository repository)
        {
            this.Repository = repository;
        }

        public TBaseEntity GetByID<TBaseEntity>(int id) where TBaseEntity : BaseEntity
        {
            return this.Repository.GetByID<TBaseEntity>(id);
        }
    }
}
