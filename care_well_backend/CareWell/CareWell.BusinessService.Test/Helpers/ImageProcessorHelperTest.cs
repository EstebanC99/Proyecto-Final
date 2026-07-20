using CareWell.BusinessService.Helpers;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using System.Text;

namespace CareWell.BusinessService.Test.Helpers
{
    public class ImageProcessorHelperTest
    {
        public class ElMetodo_GetImage : ImageProcessorHelperTest
        {
            [Fact]
            public void Retorna_null_si_la_cadena_de_caracteres_es_nula_o_vacia()
            {
                // Arrange
                var imagenString = string.Empty;

                // Action
                var resultado = ImageProcessorHelper.GetImage(imagenString);

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void Retorna_el_array_de_bytes_de_la_cadena_enviada_por_parametro()
            {
                // Arrange
                var bytesEsperados = Encoding.UTF8.GetBytes("Hola soy una imagen");
                var imagenString = Convert.ToBase64String(bytesEsperados);

                // Action
                var resultado = ImageProcessorHelper.GetImage(imagenString);

                // Assert
                Assert.Equal(bytesEsperados, resultado);
            }

            [Fact]
            public void Retorna_una_instancia_del_tipo_array_de_bytes()
            {
                // Arrange
                var bytesEsperados = Encoding.UTF8.GetBytes("Hola soy una imagen");
                var imagenString = Convert.ToBase64String(bytesEsperados);

                // Action
                var resultado = ImageProcessorHelper.GetImage(imagenString);

                // Assert
                Assert.IsType<byte[]>(resultado);
            }

            [Fact]
            public void Si_no_puede_convertir_la_cadena_en_un_array_de_bytes_valido_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                var imagenString = "Soy una imagen falsa";

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => ImageProcessorHelper.GetImage(imagenString));
                Assert.Equal(Mensajes.LaImagenNoPudoRecuperarse, exception.Message);
            }
        }
    }
}
