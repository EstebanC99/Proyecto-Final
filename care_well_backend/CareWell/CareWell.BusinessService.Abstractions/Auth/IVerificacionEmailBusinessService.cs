using CareWell.Commands.Auth;

namespace CareWell.BusinessService.Abstractions.Auth
{
    public interface IVerificacionEmailBusinessService
    {
        void EnviarCodigo(EnviarCodigoVerificacionCommand command);
        void Verificar(VerificarEmailCommand command);
    }
}
