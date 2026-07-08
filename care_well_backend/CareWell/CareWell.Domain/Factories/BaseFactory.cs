namespace CareWell.Domain.Factories
{
    public class BaseFactory : IBaseFactory
    {
        public TEntity Crear<TEntity>() where TEntity : class, new()
        {
            return new TEntity();
        }
    }
}
