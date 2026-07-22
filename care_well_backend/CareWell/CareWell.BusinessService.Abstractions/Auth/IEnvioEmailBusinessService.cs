using CareWell.Commands.Auth;

namespace CareWell.BusinessService.Abstractions.Auth
{
    public interface IEnvioEmailBusinessService
    {
        void Enviar(EnviarEmailCommand command);
    }
}
