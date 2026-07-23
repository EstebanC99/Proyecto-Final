using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Validadores
{
    public class ValidadorLimiteEnvioCodigo : IValidadorLimiteEnvioCodigo
    {
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }

        public ValidadorLimiteEnvioCodigo(IEntityLoaderDomainService entityLoaderDomainService)
        {
            this.EntityLoaderDomainService = entityLoaderDomainService;
        }

        public void ValidarCantidadEnviosUltimaHora(Usuario usuario)
        {
            var fechaHoraActual = DateTime.Now;

            var codigosUltimaHora = this.EntityLoaderDomainService
                .Query<CodigoVerificacion>()
                .Where(c => c.Usuario.ID == usuario.ID
                         && c.FechaCreacion >= fechaHoraActual.AddHours(-1))
                .ToList();

            if (codigosUltimaHora.Count >= ParametrosVerificacionCodigo.MaximoEnviosPorHora)
                throw new ValidacionDominioException(string.Format(Mensajes.SuperoElMaximoDeXEnviosDeCodigoVerificacion, ParametrosVerificacionCodigo.MaximoEnviosPorHora));

            var tiempoLimiteEspera = fechaHoraActual.AddSeconds(-ParametrosVerificacionCodigo.TiempoEsperaReenvioEnSegundos);

            if (codigosUltimaHora.Any(c => c.FechaCreacion > tiempoLimiteEspera))
                throw new ValidacionDominioException(string.Format(Mensajes.DebeEsperarXSegundosParaSolicitarOtroCodigoVerificacion, ParametrosVerificacionCodigo.TiempoEsperaReenvioEnSegundos));
        }
    }
}
