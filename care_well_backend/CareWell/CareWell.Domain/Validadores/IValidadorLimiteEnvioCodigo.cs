using CareWell.Domain.Auth;

namespace CareWell.Domain.Validadores
{
    public interface IValidadorLimiteEnvioCodigo
    {
        void ValidarCantidadEnviosUltimaHora(Usuario usuario);
    }
}