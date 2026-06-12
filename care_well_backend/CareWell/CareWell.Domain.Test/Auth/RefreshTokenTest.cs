using CareWell.Domain.Auth;
using Moq;

namespace CareWell.Domain.Test.Auth
{
    public class RefreshTokenTest : TestClassBase<RefreshToken>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new RefreshToken();
        }

        public class ElMetodo_Crear : RefreshTokenTest
        {
            private string token;
            private Usuario usuario;
            private DateTime expiracion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.token = "TK1";
                this.usuario = Mock.Of<Usuario>();
                this.expiracion = DateTime.Now;
            }

            private void Action()
            {
                this.Target.Crear(this.token,
                                  this.usuario,
                                  this.expiracion);
            }

            [Fact]
            public void Setea_la_propiedad_Token()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.token, this.Target.Token);
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
            public void Setea_la_propiedad_Expiracion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.expiracion, this.Target.Expiracion);
            }

            [Fact]
            public void Setea_la_propiedad_Revocado_en_false()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.False(this.Target.Revocado);
            }
        }

        public class ElMetodo_Revocar : RefreshTokenTest
        {
            private void Action()
            {
                this.Target.Revocar();
            }

            [Fact]
            public void Setea_la_propiedad_Revocado_en_true()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.True(this.Target.Revocado);
            }
        }

        public class ElMetodo_HabilitadoUso : RefreshTokenTest
        {
            private bool Action()
            {
                return this.Target.HabilitadoUso();
            }

            [Fact]
            public void Retorna_true_si_el_RefreshToken_no_esta_revocado_y_la_fecha_de_expiracion_es_mayor_a_la_actual()
            {
                // Arrange
                this.Target.Crear("TK1",
                                  Mock.Of<Usuario>(),
                                  DateTime.UtcNow.AddMinutes(1));

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.True(respuesta);
            }

            [Fact]
            public void Retorna_false_si_el_RefreshToken_esta_revocado()
            {
                // Arrange
                this.Target.Revocar();

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.False(respuesta);
            }

            [Fact]
            public void Retorna_false_si_la_fecha_de_expiracion_del_RefreshToken_es_menor_a_la_actual()
            {
                // Arrange
                this.Target.Crear("TK1",
                                  Mock.Of<Usuario>(),
                                  DateTime.UtcNow.AddMinutes(-1));

                // Action
                var respuesta = this.Action();

                // Assert
                Assert.False(respuesta);
            }
        }
    }
}
