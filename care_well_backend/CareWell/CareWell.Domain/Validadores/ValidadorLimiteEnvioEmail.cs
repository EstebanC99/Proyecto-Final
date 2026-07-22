using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Validadores
{
    public class ValidadorLimiteEnvioEmail : IValidadorLimiteEnvioEmail
    {
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }

        public ValidadorLimiteEnvioEmail(IEntityLoaderDomainService entityLoaderDomainService)
        {
            this.EntityLoaderDomainService = entityLoaderDomainService;
        }

        public void ValidarCantidadEnviosUltimaHora(Usuario usuario)
        {
            var fechaHoraActual = DateTime.Now;

            var codigosUltimaHora = this.EntityLoaderDomainService
                .Query<CodigoVerificacionEmail>()
                .Where(c => c.Usuario.ID == usuario.ID
                         && c.FechaCreacion >= fechaHoraActual.AddHours(-1))
                .ToList();

            if (codigosUltimaHora.Count >= ParametrosVerificacionEmail.MaximoEnviosPorHora)
                throw new ValidacionDominioException(string.Format(Mensajes.SuperoElMaximoDeXEnviosDeCodigoVerificacionEmail, ParametrosVerificacionEmail.MaximoEnviosPorHora));

            var tiempoLimiteEspera = fechaHoraActual.AddSeconds(-ParametrosVerificacionEmail.TiempoEsperaReenvioEnSegundos);

            if (codigosUltimaHora.Any(c => c.FechaCreacion > tiempoLimiteEspera))
                throw new ValidacionDominioException(string.Format(Mensajes.DebeEsperarXSegundosParaSolicitarOtroCodigoVerificacionEmail, ParametrosVerificacionEmail.TiempoEsperaReenvioEnSegundos));
        }
    }
}
