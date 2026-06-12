namespace CareWell.Domain.Test
{
    public abstract class TestClassBase<TBaseEntity> where TBaseEntity : BaseEntity
    {
        protected TBaseEntity Target { get; set; }

        protected TestClassBase()
        {
            this.InitializeTest();
        }

        protected virtual void InitializeTest()
        {

        }
    }
}
