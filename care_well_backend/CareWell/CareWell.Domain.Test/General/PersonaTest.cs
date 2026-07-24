using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
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

        public class ElMetodo_ValidarIdentidad : PersonaTest
        {
            private TextoDocumentoReconocido textoDocumentoReconocido;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.textoDocumentoReconocido = new TextoDocumentoReconocido(
                    NumeroDocumento: "41567829",
                    Nombre: "Esteban",
                    Apellido: "Robertiño"
                );

                #region Modificar Perfil

                var modificarPerfil = new ModificarPerfil(
                    Nombre: this.textoDocumentoReconocido.Nombre.ToLower(),
                    Apellido: this.textoDocumentoReconocido.Apellido.ToLower(),
                    Documento: this.textoDocumentoReconocido.NumeroDocumento,
                    FechaNacimiento: DateTime.Today,
                    Telefono: "3364562256",
                    Imagen: new byte[8]
                );

                this.Target.ModificarPerfil(modificarPerfil,
                                            Mock.Of<Persona>(),
                                            Mock.Of<IValidadorPermisoAccion>());

                #endregion
            }

            private void Action()
            {
                this.Target.ValidarIdentidad(this.textoDocumentoReconocido);
            }

            [Fact]
            public void Si_el_Documento_no_coincide_mantiene_IdentidadValidada_en_false_y_FechaValidacionIdentidad_en_null()
            {
                // Arrange
                this.textoDocumentoReconocido = this.textoDocumentoReconocido with { NumeroDocumento = "12345678" };

                // Action
                this.Action();

                // Assert
                Assert.False(this.Target.IdentidadValidada);
                Assert.Null(this.Target.FechaValidacionIdentidad);
            }

            [Fact]
            public void Si_el_Nombre_no_coincide_mantiene_IdentidadValidada_en_false_y_FechaValidacionIdentidad_en_null()
            {
                // Arrange
                this.textoDocumentoReconocido = this.textoDocumentoReconocido with { Nombre = "Nombre X" };

                // Action
                this.Action();

                // Assert
                Assert.False(this.Target.IdentidadValidada);
                Assert.Null(this.Target.FechaValidacionIdentidad);
            }

            [Fact]
            public void Si_el_Apellido_no_coincide_mantiene_IdentidadValidada_en_false_y_FechaValidacionIdentidad_en_null()
            {
                // Arrange
                this.textoDocumentoReconocido = this.textoDocumentoReconocido with { Apellido = "Apellido X" };

                // Action
                this.Action();

                // Assert
                Assert.False(this.Target.IdentidadValidada);
                Assert.Null(this.Target.FechaValidacionIdentidad);
            }

            [Fact]
            public void Si_el_Documento_y_el_Nombre_y_el_Apellido_coinciden_setea_la_propiedad_IdentidadValidada_en_true()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.True(this.Target.IdentidadValidada);
            }

            [Fact]
            public void Si_el_Documento_y_el_Nombre_y_el_Apellido_coinciden_setea_la_propiedad_FechaValidacionIdentidad()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.NotNull(this.Target.FechaValidacionIdentidad);
            }
        }

        public class ElMetodo_ValidarCrearUsuario : PersonaTest
        {
            private Mock<IEntityLoaderDomainService> entityLoaderDomainService;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
                this.entityLoaderDomainService.Setup(s => s.Query<Usuario>()).Returns(new List<Usuario>().AsQueryable);
            }

            private void Action()
            {
                this.Target.ValidarCrearUsuario(this.entityLoaderDomainService.Object);
            }

            [Fact]
            public void Si_existe_un_Usuario_para_la_persona_arroja_un_CuentaExistenteException_con_mensaje_informativo()
            {
                // Arrange
                this.entityLoaderDomainService.Setup(s => s.Query<Usuario>()).Returns(new List<Usuario> { Mock.Of<Usuario>(u => u.Persona == this.Target) }.AsQueryable);

                // Action & Assert
                var excepcion = Assert.Throws<CuentaExistenteException>(() => this.Action());
                Assert.Equal(Mensajes.PersonaYaTieneUsuario, excepcion.Message);
            }

            [Fact]
            public void Si_no_existe_un_Usuario_para_la_persona_no_arroja_excepcion()
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
