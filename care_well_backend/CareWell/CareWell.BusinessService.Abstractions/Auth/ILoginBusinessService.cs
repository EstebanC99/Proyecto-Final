using CareWell.DataViews.Auth;
using CareWell.Queries.Auth;

namespace CareWell.BusinessService.Abstractions.Auth
{
    public interface ILoginBusinessService
    {
        LoginDataView Login(LoginQuery query);
    }
}
