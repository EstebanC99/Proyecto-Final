using CareWell.Domain.General;
using CareWell.Domain.ValueObjects.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Test.General
{
    public class PersonaTest : TestClassBase<Persona>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new Persona();
        }

        public class ElMetodo_Crear : PersonaTest
        {
            private CrearCuenta crearCuenta;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.crearCuenta = new CrearCuenta("Usuario",
                                                   "Prueba",
                                                   "1234",
                                                   DateTime.Today,
                                                   "email@example.com",
                                                   "3364562256");
            }

            private void Action()
            {
                this.Target.Crear(this.crearCuenta);
            }

            [Fact]
            public void Si_Nombre_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearCuenta = new CrearCuenta(null,
                                                   "Prueba",
                                                   "1234",
                                                   DateTime.Today,
                                                   "email@example.com",
                                                   "3364562256");

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NombreRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Apellido_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearCuenta = new CrearCuenta("Usuario",
                                                   null,
                                                   "1234",
                                                   DateTime.Today,
                                                   "email@example.com",
                                                   "3364562256");

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ApellidoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Documento_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearCuenta = new CrearCuenta("Usuario",
                                                   "Prueba",
                                                   null,
                                                   DateTime.Today,
                                                   "email@example.com",
                                                   "3364562256");

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.DocumentoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_FechaNacimiento_no_fue_especificada_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearCuenta = new CrearCuenta("Usuario",
                                                   "Prueba",
                                                   "1234",
                                                   default,
                                                   "email@example.com",
                                                   "3364562256");

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.FechaNacimientoRequerida, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Email_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearCuenta = new CrearCuenta("Usuario",
                                                   "Prueba",
                                                   "1234",
                                                   DateTime.Today,
                                                   null,
                                                   "3364562256");

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.EmailRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Telefono_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearCuenta = new CrearCuenta("Usuario",
                                                   "Prueba",
                                                   "1234",
                                                   DateTime.Today,
                                                   "email@example.com",
                                                   null);

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.TelefonoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Setea_la_propiedad_Nombre()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearCuenta.Nombre, this.Target.Nombre);
            }

            [Fact]
            public void Setea_la_propiedad_Apellido()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearCuenta.Apellido, this.Target.Apellido);
            }

            [Fact]
            public void Setea_la_propiedad_Documento()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearCuenta.Documento, this.Target.Documento);
            }

            [Fact]
            public void Setea_la_propiedad_FechaNacimiento()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearCuenta.FechaNacimiento, this.Target.FechaNacimiento);
            }

            [Fact]
            public void Setea_la_propiedad_Email()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearCuenta.Email, this.Target.Email);
            }

            [Fact]
            public void Setea_la_propiedad_Telefono()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearCuenta.Telefono, this.Target.Telefono);
            }
        }
    }
}
