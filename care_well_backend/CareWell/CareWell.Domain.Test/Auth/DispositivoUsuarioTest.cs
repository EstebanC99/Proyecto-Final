using CareWell.Domain.Auth;
using CareWell.Domain.ValueObjects.Auth;
using CareWell.Global.Enumeraciones.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Auth
{
    public class DispositivoUsuarioTest : TestClassBase<DispositivoUsuario>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new DispositivoUsuario();
        }

        public class ElMetodo_Registrar : DispositivoUsuarioTest
        {
            private RegistrarDispositivo registrarDispositivo;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.registrarDispositivo = new RegistrarDispositivo
                (
                    Usuario: Mock.Of<Usuario>(),
                    Token: "token123",
                    Plataforma: Global.Enumeraciones.Auth.DispositivoPlataformasEnum.Android
                );
            }

            private void Action()
            {
                this.Target.Registrar(this.registrarDispositivo);
            }

            [Fact]
            public void Si_el_Usuario_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.registrarDispositivo = this.registrarDispositivo with { Usuario = null };

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.UsuarioNoExiste, excepcion.Message);
            }

            [Theory]
            [InlineData(null)]
            [InlineData("")]
            [InlineData("   ")]
            public void Si_el_Token_es_vacio_arroja_un_ValidacionDominioException_con_mensaje_informativo(string? tokenInvalido)
            {
                // Arrange
                this.registrarDispositivo = this.registrarDispositivo with { Token = tokenInvalido! };

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.TokenDispositivoRequerido, excepcion.Message);
            }

            [Fact]
            public void Si_el_valor_de_Plataforma_no_pertenece_a_la_enumeracion_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.registrarDispositivo = this.registrarDispositivo with { Plataforma = (DispositivoPlataformasEnum)3 };

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.PlataformaDispositivoInvalida, excepcion.Message);
            }

            [Fact]
            public void Setea_la_propiedad_Usuario()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.registrarDispositivo.Usuario, this.Target.Usuario);
            }

            [Fact]
            public void Setea_la_propiedad_Token()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarDispositivo.Token, this.Target.Token);
            }

            [Fact]
            public void Setea_la_propiedad_Plataforma()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.registrarDispositivo.Plataforma, this.Target.Plataforma);
            }

            [Fact]
            public void Setea_la_propiedad_Activo_en_true()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.True(this.Target.Activo);
            }

            [Fact]
            public void Setea_la_propiedad_FechaAlta_con_la_FechaHoraActual()
            {
                // Arrange
                var fechaHoraInicioEjecucion = DateTime.Now;

                // Action
                this.Action();

                // Assert
                var fechaHoraFinEjecucion = DateTime.Now;
                Assert.True(this.Target.FechaAlta >= fechaHoraInicioEjecucion && this.Target.FechaAlta <= fechaHoraFinEjecucion);
            }

            [Fact]
            public void Setea_la_propiedad_FechaUltimoUso_con_la_FechaHoraActual()
            {
                // Arrange
                var fechaHoraInicioEjecucion = DateTime.Now;

                // Action
                this.Action();

                // Assert
                var fechaHoraFinEjecucion = DateTime.Now;
                Assert.True(this.Target.FechaUltimoUso >= fechaHoraInicioEjecucion && this.Target.FechaUltimoUso <= fechaHoraFinEjecucion);
            }
        }

        public class ElMetodo_RegistrarUso : DispositivoUsuarioTest
        {
            private Usuario usuario;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.usuario = Mock.Of<Usuario>();
            }

            private void Action()
            {
                this.Target.RegistrarUso(this.usuario);
            }

            [Fact]
            public void Si_el_Usuario_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.usuario = null;

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.UsuarioNoExiste, excepcion.Message);
            }

            [Fact]
            public void Setea_la_propiedad_Usuario()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.usuario, this.Target.Usuario);
            }

            [Fact]
            public void Setea_la_propiedad_Activo_en_true()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.True(this.Target.Activo);
            }

            [Fact]
            public void Setea_la_propiedad_FechaUltimoUso_con_la_FechaHoraActual()
            {
                // Arrange
                var fechaHoraInicioEjecucion = DateTime.Now;

                // Action
                this.Action();

                // Assert
                var fechaHoraFinEjecucion = DateTime.Now;
                Assert.True(this.Target.FechaUltimoUso >= fechaHoraInicioEjecucion && this.Target.FechaUltimoUso <= fechaHoraFinEjecucion);
            }
        }

        public class ElMetodo_Desactivar : DispositivoUsuarioTest
        {
            [Fact]
            public void Setea_la_propiedad_Activo_en_false()
            {
                // Arrange

                // Action
                this.Target.Desactivar();

                // Assert
                Assert.False(this.Target.Activo);
            }
        }

        public class ElMetodo_PerteneceA : DispositivoUsuarioTest
        {
            private Usuario usuario;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.usuario = Mock.Of<Usuario>(u => u.ID == 99);

                this.Target.RegistrarUso(this.usuario);
            }

            private bool Action()
            {
                return this.Target.PerteneceA(this.usuario);
            }

            [Fact]
            public void Retorna_false_si_el_usuario_es_null()
            {
                // Arrange
                this.usuario = null;

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Retorna_false_si_el_usuario_pasado_por_parametro_no_coincide_con_el_del_dispositivo()
            {
                // Arrange
                this.Target.RegistrarUso(Mock.Of<Usuario>());

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Retorna_true_si_el_usuario_pasado_por_parametro_coincide_con_el_del_dispositivo()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.True(resultado);
            }

            [Fact]
            public void Retorna_una_instancia_del_tipo_bool()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<bool>(resultado);
            }
        }
    }
}
