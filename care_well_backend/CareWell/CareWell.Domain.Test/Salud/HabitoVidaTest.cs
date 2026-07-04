using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Salud
{
    public class HabitoVidaTest : TestClassBase<HabitoVida>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new HabitoVida();
        }

        public class ElMetodo_Crear : HabitoVidaTest
        {
            private CrearHabitoVida crearHabitoVida;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.crearHabitoVida = new CrearHabitoVida(
                    Persona: Mock.Of<Persona>(),
                    Colaborador: Mock.Of<Persona>(),
                    TipoHabito: Mock.Of<TipoHabitoVida>(),
                    Descripcion: "Habito X"
                );

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            }

            private void Action()
            {
                this.Target.Crear(this.crearHabitoVida,
                                  this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Si_la_Persona_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearHabitoVida = this.crearHabitoVida with { Persona = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.PersonaNoExiste, exception.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeRegistrarHabitos_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeRegistrarHabitos(this.crearHabitoVida.Persona, this.crearHabitoVida.Colaborador), Times.Once);
            }

            [Fact]
            public void Si_el_TipoHabito_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearHabitoVida = this.crearHabitoVida with { TipoHabito = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.TipoHabitoRequerido, exception.Message);
            }

            [Fact]
            public void Si_la_Descripcion_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearHabitoVida = this.crearHabitoVida with { Descripcion = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.LaDescripcionEsRequerida, exception.Message);
            }

            [Fact]
            public void Setea_la_propiedad_Persona()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearHabitoVida.Persona, this.Target.Persona);
            }

            [Fact]
            public void Setea_la_propiedad_Tipo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearHabitoVida.TipoHabito, this.Target.Tipo);
            }

            [Fact]
            public void Setea_la_propiedad_Descripcion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearHabitoVida.Descripcion, this.Target.Descripcion);
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
        }

        public class ElMetodo_Modificar : HabitoVidaTest
        {
            private ModificarHabitoVida modificarHabitoVida;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.modificarHabitoVida = new ModificarHabitoVida(
                    Colaborador: Mock.Of<Persona>(),
                    TipoHabito: Mock.Of<TipoHabitoVida>(),
                    Descripcion: "Habito Y"
                );

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();

                #region Crear

                var crearHabitoVida = new CrearHabitoVida(
                    Persona: Mock.Of<Persona>(),
                    Colaborador: Mock.Of<Persona>(),
                    TipoHabito: Mock.Of<TipoHabitoVida>(),
                    Descripcion: "Habito X"
                );

                this.Target.Crear(crearHabitoVida,
                                  Mock.Of<IValidadorPermisoAccion>());

                #endregion
            }

            private void Action()
            {
                this.Target.Modificar(this.modificarHabitoVida,
                                      this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Si_el_habito_no_esta_activo_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.Target = new HabitoVida();

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NoSePuedeModificarUnHabitoInactivo, exception.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeRegistrarHabitos_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeRegistrarHabitos(this.Target.Persona, this.modificarHabitoVida.Colaborador), Times.Once);
            }

            [Fact]
            public void Si_el_TipoHabito_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.modificarHabitoVida = this.modificarHabitoVida with { TipoHabito = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.TipoHabitoRequerido, exception.Message);
            }

            [Fact]
            public void Si_la_Descripcion_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.modificarHabitoVida = this.modificarHabitoVida with { Descripcion = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.LaDescripcionEsRequerida, exception.Message);
            }

            [Fact]
            public void Setea_la_propiedad_Tipo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.modificarHabitoVida.TipoHabito, this.Target.Tipo);
            }

            [Fact]
            public void Setea_la_propiedad_Descripcion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarHabitoVida.Descripcion, this.Target.Descripcion);
            }
        }

        public class ElMetodo_Eliminar : HabitoVidaTest
        {
            private Persona colaborador;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.colaborador = Mock.Of<Persona>();

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();

                #region Crear

                var crearHabitoVida = new CrearHabitoVida(
                    Persona: Mock.Of<Persona>(),
                    Colaborador: Mock.Of<Persona>(),
                    TipoHabito: Mock.Of<TipoHabitoVida>(),
                    Descripcion: "Habito X"
                );

                this.Target.Crear(crearHabitoVida,
                                  Mock.Of<IValidadorPermisoAccion>());

                #endregion
            }

            private void Action()
            {
                this.Target.Eliminar(this.colaborador,
                                     this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeRegistrarHabitos_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeRegistrarHabitos(this.Target.Persona, this.colaborador), Times.Once);
            }

            [Fact]
            public void Setea_la_propiedad_Activo_en_false()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.False(this.Target.Activo);
            }
        }

        public class ElMetodo_CrearRealizacion : HabitoVidaTest
        {
            private string? comentarios;
            private Mock<IBaseFactory> baseFactory;
            private Mock<HabitoVidaRealizacion> realizacion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.comentarios = "Comentarios X";
                this.realizacion = new Mock<HabitoVidaRealizacion>();

                this.baseFactory = new Mock<IBaseFactory>();
                this.baseFactory.Setup(s => s.Crear<HabitoVidaRealizacion>()).Returns(this.realizacion.Object);

                #region Crear

                var crearHabitoVida = new CrearHabitoVida(
                    Persona: Mock.Of<Persona>(),
                    Colaborador: Mock.Of<Persona>(),
                    TipoHabito: Mock.Of<TipoHabitoVida>(),
                    Descripcion: "Habito X"
                );

                this.Target.Crear(crearHabitoVida,
                                  Mock.Of<IValidadorPermisoAccion>());

                #endregion
            }

            private void Action()
            {
                this.Target.CrearRealizacion(this.comentarios,
                                             this.baseFactory.Object);
            }

            [Fact]
            public void Si_el_habito_no_esta_activo_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.Target = new HabitoVida();

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NoSePuedeIndicarRealizacionDeUnHabitoInactivo, exception.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_HabitoVidaRealizacion_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<HabitoVidaRealizacion>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_de_la_Realizacion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.realizacion.Verify(v => v.Crear(this.Target,
                                                     this.comentarios), Times.Once);
            }

            [Fact]
            public void Agrega_la_realizacion_a_la_lista_de_Realizaciones()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Contains(this.realizacion.Object, this.Target.Realizaciones);
            }
        }

        public class ElMetodo_ModificarRealizacion : HabitoVidaTest
        {
            private int realizacionID;
            private string? comentarios;
            private Mock<HabitoVidaRealizacion> realizacion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.realizacionID = 1;
                this.comentarios = "Comentarios X";

                this.realizacion = new Mock<HabitoVidaRealizacion>();
                this.realizacion.Setup(s => s.ID).Returns(this.realizacionID);

                this.Target.Realizaciones.Add(this.realizacion.Object);
            }

            private void Action()
            {
                this.Target.ModificarRealizacion(this.realizacionID,
                                                 this.comentarios);
            }

            [Fact]
            public void Si_ela_realizacion_seleccionada_no_se_encuentra_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.Target.Realizaciones.Clear();

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NoSePudoEncontrarLaRealizacionDeHabitoSeleccionada, exception.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Modificar_de_la_Realizacion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.realizacion.Verify(v => v.Modificar(this.comentarios), Times.Once);
            }
        }

        public class ElMetodo_EliminarRealizacion : HabitoVidaTest
        {
            private int realizacionID;
            private Mock<HabitoVidaRealizacion> realizacion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.realizacionID = 1;

                this.realizacion = new Mock<HabitoVidaRealizacion>();
                this.realizacion.Setup(s => s.ID).Returns(this.realizacionID);

                this.Target.Realizaciones.Add(this.realizacion.Object);
            }

            private void Action()
            {
                this.Target.EliminarRealizacion(this.realizacionID);
            }

            [Fact]
            public void Si_ela_realizacion_seleccionada_no_se_encuentra_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.Target.Realizaciones.Clear();

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NoSePudoEncontrarLaRealizacionDeHabitoSeleccionada, exception.Message);
            }

            [Fact]
            public void Elimina_la_realizacion_de_la_lista_de_Realizaciones()
            {
                // Arrange
                this.realizacion.CallBase = true;

                // Action
                this.Action();

                // Assert
                Assert.DoesNotContain(this.realizacion.Object, this.Target.Realizaciones);
            }
        }
    }
}
