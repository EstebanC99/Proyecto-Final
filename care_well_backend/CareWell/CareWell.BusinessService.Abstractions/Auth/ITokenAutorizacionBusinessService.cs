using CareWell.Queries.Auth;

namespace CareWell.BusinessService.Abstractions.Auth
{
    public interface ITokenAutorizacionBusinessService
    {
        string GenerarTokenAcceso(GenerarTokenAccesoQuery query);
    }
}
