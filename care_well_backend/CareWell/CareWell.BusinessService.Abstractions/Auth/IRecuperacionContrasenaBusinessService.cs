using CareWell.Commands.Auth;

namespace CareWell.BusinessService.Abstractions.Auth
{
    public interface IRecuperacionContrasenaBusinessService
    {
        void SolicitarReset(SolicitarResetContrasenaCommand command);
        void ConfirmarReset(ConfirmarResetContrasenaCommand command);
    }
}
