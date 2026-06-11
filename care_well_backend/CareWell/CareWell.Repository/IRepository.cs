using CareWell.Domain;

namespace CareWell.Repository
{
    public interface IRepository<TBaseEntity> where TBaseEntity : BaseEntity
    {
        void Add(TBaseEntity entity);
        void Remove(TBaseEntity entity);
        TBaseEntity GetByID(int id);
    }
}