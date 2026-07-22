using CareWell.Domain.Auth;

namespace CareWell.Domain.Validadores
{
    public interface IValidadorLimiteEnvioEmail
    {
        void ValidarCantidadEnviosUltimaHora(Usuario usuario);
    }
}