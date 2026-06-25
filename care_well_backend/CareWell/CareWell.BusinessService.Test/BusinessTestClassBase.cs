using CareWell.Repository;
using Moq;

namespace CareWell.BusinessService.Test
{
    public abstract class BusinessTestClassBase<TBusinessService> where TBusinessService : class
    {
        protected Mock<IUnitOfWork> unitOfWork;

        protected TBusinessService Target { get; set; }

        protected BusinessTestClassBase()
        {
            this.InitializeTest();
        }

        protected virtual void InitializeTest()
        {
            this.unitOfWork = new Mock<IUnitOfWork>();
        }
    }
}
