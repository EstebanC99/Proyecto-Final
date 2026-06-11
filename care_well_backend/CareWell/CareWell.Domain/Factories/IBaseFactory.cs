namespace CareWell.Domain.Factories
{
    public interface IBaseFactory
    {
        TBaseEntity Crear<TBaseEntity>() where TBaseEntity : BaseEntity, new();
    }
}