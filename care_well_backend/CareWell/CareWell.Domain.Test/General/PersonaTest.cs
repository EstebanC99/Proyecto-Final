using CareWell.Domain.General;
using CareWell.Domain.ValueObjects.General;
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
            private CrearPersona crearPersona;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.crearPersona = new CrearPersona("Usuario",
                                                     "Prueba",
                                                     "1234",
                                                     DateTime.Today,
                                                     "email@example.com",
                                                     "3364562256");
            }

            private void Action()
            {
                this.Target.Crear(this.crearPersona);
            }

            [Fact]
            public void Si_Nombre_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearPersona = new CrearPersona(null,
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
                this.crearPersona = new CrearPersona("Usuario",
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
                this.crearPersona = new CrearPersona("Usuario",
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
                this.crearPersona = new CrearPersona("Usuario",
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
            public void Setea_la_propiedad_Nombre()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearPersona.Nombre, this.Target.Nombre);
            }

            [Fact]
            public void Setea_la_propiedad_Apellido()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearPersona.Apellido, this.Target.Apellido);
            }

            [Fact]
            public void Setea_la_propiedad_Documento()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearPersona.Documento, this.Target.Documento);
            }

            [Fact]
            public void Setea_la_propiedad_FechaNacimiento()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearPersona.FechaNacimiento, this.Target.FechaNacimiento);
            }

            [Fact]
            public void Setea_la_propiedad_Email()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearPersona.Email, this.Target.Email);
            }

            [Fact]
            public void Setea_la_propiedad_Telefono()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearPersona.Telefono, this.Target.Telefono);
            }
        }

        public class ElMetodo_CrearDesdeCuenta : PersonaTest
        {
            private CrearPersona crearPersona;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.crearPersona = new CrearPersona("Usuario",
                                                   "Prueba",
                                                   "1234",
                                                   DateTime.Today,
                                                   "email@example.com",
                                                   "3364562256");
            }

            private void Action()
            {
                this.Target.CrearDesdeCuenta(this.crearPersona);
            }

            [Fact]
            public void Si_Email_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearPersona = new CrearPersona("Usuario",
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
                this.crearPersona = new CrearPersona("Usuario",
                                                   "Prueba",
                                                   "1234",
                                                   DateTime.Today,
                                                   "email@example.com",
                                                   null);

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.TelefonoRequerido, excepcionEsperada.Message);
            }
        }
    }
}
