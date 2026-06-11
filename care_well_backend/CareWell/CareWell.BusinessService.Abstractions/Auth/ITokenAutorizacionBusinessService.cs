using CareWell.DataViews.Auth;
using CareWell.Queries.Auth;

namespace CareWell.BusinessService.Abstractions.Auth
{
    public interface ITokenAutorizacionBusinessService
    {
        AccessTokenDataView GenerarTokenAcceso(GenerarTokenAccesoQuery query);
    }
}
