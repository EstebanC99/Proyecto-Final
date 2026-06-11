using CareWell.Repository;

namespace CareWell.BusinessService
{
    public abstract class BusinessService
    {
        protected IUnitOfWork UnitOfWork { get; set; }

        protected BusinessService(IUnitOfWork unitOfWork)
        {
            this.UnitOfWork = unitOfWork;
        }
    }
}
