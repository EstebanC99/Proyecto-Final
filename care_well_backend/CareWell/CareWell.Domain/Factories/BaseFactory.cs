namespace CareWell.Domain.Factories
{
    public class BaseFactory : IBaseFactory
    {
        public TBaseEntity Crear<TBaseEntity>() where TBaseEntity : BaseEntity, new()
        {
            return new TBaseEntity();
        }
    }
}
