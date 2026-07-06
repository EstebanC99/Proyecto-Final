using CareWell.Domain;

namespace CareWell.Repository
{
    public interface IRepository
    {

    }

    public interface IRepository<TBaseEntity> : IRepository
        where TBaseEntity : BaseEntity
    {
        void Add(TBaseEntity entity);
        void Remove(TBaseEntity entity);
        TBaseEntity GetByID(int id);
    }
}