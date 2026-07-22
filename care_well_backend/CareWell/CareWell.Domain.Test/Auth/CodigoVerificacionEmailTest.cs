using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.ValueObjects.Auth;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Auth
{
    public class CodigoVerificacionEmailTest : TestClassBase<CodigoVerificacionEmail>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new CodigoVerificacionEmail();
        }

        public class ElMetodo_Crear : CodigoVerificacionEmailTest
        {
            private CrearCodigoVerificacionEmail crearCodigo;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.crearCodigo = new CrearCodigoVerificacionEmail(
                    Usuario: Mock.Of<Usuario>(),
                    CodigoHash: "Codigo Hash",
                    Expiracion: DateTime.Now.AddHours(1)
                );
            }

            private void Action()
            {
                this.Target.Crear(this.crearCodigo);
            }

            [Fact]
            public void Setea_la_propiedad_Usuario()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearCodigo.Usuario, this.Target.Usuario);
            }

            [Fact]
            public void Setea_la_propiedad_CodigoHash()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearCodigo.CodigoHash, this.Target.CodigoHash);
            }

            [Fact]
            public void Setea_la_propiedad_Expiracion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearCodigo.Expiracion, this.Target.Expiracion);
            }

            [Fact]
            public void Setea_la_propiedad_Consumido_en_false()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.False(this.Target.Consumido);
            }

            [Fact]
            public void Setea_la_propiedad_IntentosFallidos_en_cero()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(default, this.Target.IntentosFallidos);
            }

            [Fact]
            public void Setea_la_propiedad_FechaCreacion_con_la_fecha_actual()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(DateTime.Now.Date, this.Target.FechaCreacion.Date);
            }
        }

        public class ElMetodo_EstaVigente : CodigoVerificacionEmailTest
        {
            protected override void InitializeTest()
            {
                base.InitializeTest();

                #region Crear

                var crearCodigo = new CrearCodigoVerificacionEmail(
                    Usuario: Mock.Of<Usuario>(),
                    CodigoHash: "Codigo Hash",
                    Expiracion: DateTime.Now.AddHours(1)
                );

                this.Target.Crear(crearCodigo);

                #endregion
            }

            private bool Action()
            {
                return this.Target.EstaVigente();
            }

            private class CodigoVerificacionEmailExpirado : CodigoVerificacionEmail
            {
                public override DateTime Expiracion => DateTime.Now.AddMinutes(-1);
            }

            private class CodigoVerificacionEmailAgotado : CodigoVerificacionEmail
            {
                public override int IntentosFallidos => ParametrosVerificacionEmail.MaximoIntentosVerificacion + 1;
            }

            [Fact]
            public void Retorna_false_si_el_codigo_esta_consumido()
            {
                // Arrange
                this.Target.Consumir();

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Retorna_false_si_la_fecha_de_expiracion_es_menor_a_la_actual()
            {
                // Arrange
                this.Target = new CodigoVerificacionEmailExpirado();

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Retorna_false_si_se_supero_la_cantidad_maxima_de_intentos_permitidos()
            {
                // Arrange
                this.Target = new CodigoVerificacionEmailAgotado();

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Retorna_true_si_el_codigo_no_esta_consumido_la_fecha_de_expiracion_es_mayor_a_la_actual_y_quedan_intentos_disponibles()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.True(resultado);
            }
        }

        public class ElMetodo_Verificar : CodigoVerificacionEmailTest
        {
            private string codigoIngresado;
            private Mock<IPasswordHasherDomainService> passwordHasherDomainService;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.codigoIngresado = "Codigo X";

                #region Crear

                var crearCodigo = new CrearCodigoVerificacionEmail(
                    Usuario: Mock.Of<Usuario>(),
                    CodigoHash: "Codigo Hash",
                    Expiracion: DateTime.Now.AddHours(1)
                );

                this.Target.Crear(crearCodigo);

                #endregion

                this.passwordHasherDomainService = new Mock<IPasswordHasherDomainService>();
                this.passwordHasherDomainService.Setup(s => s.Verificar(this.codigoIngresado, this.Target.CodigoHash)).Returns(true);
            }

            private void Action()
            {
                this.Target.Verificar(this.codigoIngresado,
                                      this.passwordHasherDomainService.Object);
            }

            [Fact]
            public void Si_el_codigo_no_esta_vigente_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.Target.Consumir();

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.CodigoVerificacionEmailInvalido, excepcion.Message);
            }

            [Fact]
            public void Si_el_codigo_ingresado_no_coincide_con_el_guardado_y_se_superaron_la_cantidad_maxima_de_intentos_setea_la_propiedad_Consumido_en_true()
            {
                // Arrange
                this.passwordHasherDomainService.Setup(s => s.Verificar(this.codigoIngresado, It.IsAny<string>())).Returns(false);
                for (int i = 1; i < ParametrosVerificacionEmail.MaximoIntentosVerificacion; i++)
                {
                    try
                    {
                        this.Action();
                    }
                    catch (ValidacionDominioException)
                    {
                        continue;
                    }
                }

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.True(this.Target.Consumido);
            }

            [Fact]
            public void Si_el_codigo_ingresado_no_coincide_con_el_guardado_y_se_superaron_la_cantidad_maxima_de_intentos_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.passwordHasherDomainService.Setup(s => s.Verificar(this.codigoIngresado, It.IsAny<string>())).Returns(false);
                for (int i = 1; i < ParametrosVerificacionEmail.MaximoIntentosVerificacion; i++)
                {
                    try
                    {
                        this.Action();
                    }
                    catch (ValidacionDominioException)
                    {
                        continue;
                    }
                }

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.CodigoVerificacionEmailVencido, excepcion.Message);
            }

            [Fact]
            public void Si_el_codigo_ingresado_no_coincide_con_el_guardado_pero_no_se_superaron_la_cantidad_maxima_de_intentos_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.passwordHasherDomainService.Setup(s => s.Verificar(this.codigoIngresado, It.IsAny<string>())).Returns(false);

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.CodigoVerificacionEmailInvalido, excepcion.Message);
            }

            [Fact]
            public void Si_el_codigo_ingresado_coincide_con_el_guardado_setea_la_propiedad_Consumido_en_true()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.True(this.Target.Consumido);
            }
        }

        public class ElMetodo_Consumir : CodigoVerificacionEmailTest
        {
            private void Action()
            {
                this.Target.Consumir();
            }

            [Fact]
            public void Setea_la_propiedad_Consumido_en_true()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.True(this.Target.Consumido);
            }
        }
    }
}
