namespace CareWell.Domain.Test
{
    public abstract class TestClassBase<TClass> where TClass : class
    {
        protected TClass Target { get; set; }

        protected TestClassBase()
        {
            this.InitializeTest();
        }

        protected virtual void InitializeTest()
        {

        }
    }
}
