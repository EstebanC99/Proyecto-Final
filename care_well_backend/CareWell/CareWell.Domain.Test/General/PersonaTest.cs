using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.General;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.General
{
    public class PersonaTest : TestClassBase<Persona>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new Persona();
        }

        public class ElMetodo_CrearDesdeCuenta : PersonaTest
        {
            private CrearModificarPersona crearPersona;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.crearPersona = new CrearModificarPersona(
                    Nombre: "Usuario",
                    Apellido: "Prueba",
                    Documento: "1234",
                    FechaNacimiento: DateTime.Today,
                    Telefono: "3364562256",
                    Email: "persona@mail.com",
                    Imagen: new byte[8]
                );
            }

            private void Action()
            {
                this.Target.CrearDesdeCuenta(this.crearPersona);
            }

            [Fact]
            public void Si_Email_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearPersona = this.crearPersona with { Email = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.EmailRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Telefono_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearPersona = this.crearPersona with { Telefono = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.TelefonoRequerido, excepcionEsperada.Message);
            }
        }

        public class ElMetodo_CrearModificar : PersonaTest
        {
            private CrearModificarPersona crearPersona;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.crearPersona = new CrearModificarPersona(
                    Nombre: "Usuario",
                    Apellido: "Prueba",
                    Documento: "1234",
                    FechaNacimiento: DateTime.Today,
                    Telefono: "3364562256",
                    Email: "persona@mail.com",
                    Imagen: new byte[8]
                );
            }

            private void Action()
            {
                this.Target.CrearModificar(this.crearPersona);
            }

            [Fact]
            public void Si_Nombre_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearPersona = this.crearPersona with { Nombre = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NombreRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Apellido_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearPersona = this.crearPersona with { Apellido = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ApellidoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Documento_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearPersona = this.crearPersona with { Documento = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.DocumentoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_FechaNacimiento_no_fue_especificada_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearPersona = this.crearPersona with { FechaNacimiento = default };

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
            public void Setea_la_propiedad_Telefono()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearPersona.Telefono, this.Target.Telefono);
            }

            [Fact]
            public void Setea_la_propiedad_Imagen()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearPersona.Imagen, this.Target.Imagen);
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
        }

        public class ElMetodo_ModificarPerfil : PersonaTest
        {
            private ModificarPerfil modificarPerfil;
            private Persona colaborador;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.modificarPerfil = new ModificarPerfil(
                    Nombre: "Usuario",
                    Apellido: "Prueba",
                    Documento: "1234",
                    FechaNacimiento: DateTime.Today,
                    Telefono: "3364562256",
                    Imagen: new byte[8]
                );

                this.colaborador = Mock.Of<Persona>();

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            }

            private void Action()
            {
                this.Target.ModificarPerfil(this.modificarPerfil,
                                            this.colaborador,
                                            this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeModificarPerfil_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeModificarPerfil(this.Target, this.colaborador), Times.Once);
            }

            [Fact]
            public void Si_Nombre_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.modificarPerfil = this.modificarPerfil with { Nombre = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NombreRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Apellido_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.modificarPerfil = this.modificarPerfil with { Apellido = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ApellidoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Documento_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.modificarPerfil = this.modificarPerfil with { Documento = null };

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.DocumentoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_FechaNacimiento_no_fue_especificada_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.modificarPerfil = this.modificarPerfil with { FechaNacimiento = default };

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
                Assert.Equal(this.modificarPerfil.Nombre, this.Target.Nombre);
            }

            [Fact]
            public void Setea_la_propiedad_Apellido()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarPerfil.Apellido, this.Target.Apellido);
            }

            [Fact]
            public void Setea_la_propiedad_Documento()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarPerfil.Documento, this.Target.Documento);
            }

            [Fact]
            public void Setea_la_propiedad_FechaNacimiento()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarPerfil.FechaNacimiento, this.Target.FechaNacimiento);
            }

            [Fact]
            public void Setea_la_propiedad_Telefono()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarPerfil.Telefono, this.Target.Telefono);
            }

            [Fact]
            public void Setea_la_propiedad_Imagen()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarPerfil.Imagen, this.Target.Imagen);
            }
        }
    }
}
