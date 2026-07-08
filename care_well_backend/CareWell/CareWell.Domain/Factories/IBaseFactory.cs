namespace CareWell.Domain.Factories
{
    public interface IBaseFactory
    {
        TEntity Crear<TEntity>() where TEntity : class, new();
    }
}