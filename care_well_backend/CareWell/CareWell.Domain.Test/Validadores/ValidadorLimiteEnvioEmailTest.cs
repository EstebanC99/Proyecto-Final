using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.Validadores;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Validadores
{
    public class ValidadorLimiteEnvioEmailTest : TestClassBase<ValidadorLimiteEnvioEmail>
    {
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();

            this.Target = new ValidadorLimiteEnvioEmail(this.entityLoaderDomainService.Object);
        }

        public class ElMetodo_ValidarCantidadEnviosUltimaHora : ValidadorLimiteEnvioEmailTest
        {
            private Usuario usuario;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.usuario = Mock.Of<Usuario>(u => u.ID == 1);

                this.entityLoaderDomainService.Setup(s => s.Query<CodigoVerificacionEmail>()).Returns(new List<CodigoVerificacionEmail>().AsQueryable);
            }

            private void Action()
            {
                this.Target.ValidarCantidadEnviosUltimaHora(this.usuario);
            }

            [Fact]
            public void Si_la_cantidad_de_codigos_generados_en_la_ultima_hora_para_el_usuario_superan_el_limite_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                var codigosGenerados = new List<CodigoVerificacionEmail>();

                for (int i = 0; i < ParametrosVerificacionEmail.MaximoEnviosPorHora; i++)
                {
                    codigosGenerados.Add(Mock.Of<CodigoVerificacionEmail>(c => c.Usuario == this.usuario && c.FechaCreacion == DateTime.Now));
                }

                this.entityLoaderDomainService.Setup(s => s.Query<CodigoVerificacionEmail>()).Returns(codigosGenerados.AsQueryable);

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(string.Format(Mensajes.SuperoElMaximoDeXEnviosDeCodigoVerificacionEmail, ParametrosVerificacionEmail.MaximoEnviosPorHora), excepcion.Message);
            }

            [Fact]
            public void Si_alguno_de_los_codigo_generados_fue_enviado_recientemente_y_no_cumple_con_el_tiempo_minimo_de_espera_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.entityLoaderDomainService.Setup(s => s.Query<CodigoVerificacionEmail>()).Returns(new List<CodigoVerificacionEmail>
                {
                    Mock.Of<CodigoVerificacionEmail>(c => c.Usuario == this.usuario && c.FechaCreacion == DateTime.Now)
                }.AsQueryable);

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(string.Format(Mensajes.DebeEsperarXSegundosParaSolicitarOtroCodigoVerificacionEmail, ParametrosVerificacionEmail.TiempoEsperaReenvioEnSegundos), excepcion.Message);
            }

            [Fact]
            public void En_cualquier_otro_caso_no_arroja_excepcion()
            {
                // Arrange

                // Action
                var excepcion = Record.Exception(() => this.Action());

                // Assert
                Assert.Null(excepcion);
            }
        }
    }
}
