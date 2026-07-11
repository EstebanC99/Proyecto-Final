using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.BusinessService.Helpers
{
    public static class ImageProcessorHelper
    {
        public static byte[]? GetImage(string? imageString)
        {
            if (string.IsNullOrEmpty(imageString))
                return null;

            try
            {
                return Convert.FromBase64String(imageString);
            }
            catch (Exception)
            {
                throw new ValidacionDominioException(Mensajes.LaImagenNoPudoRecuperarse);
            }
        }
    }
}
