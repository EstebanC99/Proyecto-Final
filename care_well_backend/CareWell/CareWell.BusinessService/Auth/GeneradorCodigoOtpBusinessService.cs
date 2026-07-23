using CareWell.Domain.DomainServices.Auth;
using CareWell.Global.Constantes.Auth;
using System.Security.Cryptography;

namespace CareWell.BusinessService.Auth
{
    public class GeneradorCodigoOtpBusinessService : IGeneradorCodigoOtpDomainService
    {
        public string Generar()
        {
            var maximoExclusivo = (int)Math.Pow(10, ParametrosVerificacionCodigo.LongitudCodigo);

            var numero = RandomNumberGenerator.GetInt32(0, maximoExclusivo);

            return numero.ToString().PadLeft(ParametrosVerificacionCodigo.LongitudCodigo, '0');
        }
    }
}
