using CareWell.BusinessService.Auth;
using CareWell.Global.Constantes.Auth;

namespace CareWell.BusinessService.Test.Auth
{
    public class GeneradorCodigoOtpBusinessTest : BusinessTestClassBase<GeneradorCodigoOtpBusinessService>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new GeneradorCodigoOtpBusinessService();
        }

        public class ElMetodo_Generar : GeneradorCodigoOtpBusinessTest
        {
            private string Action()
            {
                return this.Target.Generar();
            }

            [Fact]
            public void Retorna_un_numero_siempre_mayor_o_igual_a_cero()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.True(int.Parse(resultado) >= default(int));
            }

            [Fact]
            public void Retorna_un_numero_siempre_menor_al_maximo_exclusivo()
            {
                // Arrange
                var maximoExclusivo = (int)Math.Pow(10, ParametrosVerificacionCodigo.LongitudCodigo);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.True(int.Parse(resultado) < maximoExclusivo);
            }

            [Fact]
            public void Retorna_siempre_un_string_de_seis_caracteres()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.True(resultado.Length == ParametrosVerificacionCodigo.LongitudCodigo);
            }
        }
    }
}
