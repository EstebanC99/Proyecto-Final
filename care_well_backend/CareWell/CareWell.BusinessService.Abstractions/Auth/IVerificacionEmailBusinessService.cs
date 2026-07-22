using CareWell.Commands.Auth;

namespace CareWell.BusinessService.Abstractions.Auth
{
    public interface IVerificacionEmailBusinessService
    {
        void EnviarCodigo(EnviarCodigoVerificacionEmailCommand command);
        void Verificar(VerificarEmailCommand command);
    }
}
