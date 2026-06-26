using CareWell.Domain.Auth;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Global.Constantes.EquipoCuidado;
using Moq;

namespace CareWell.Domain.Test.Validadores
{
    public class ValidadorPermisoAccionTest : TestClassBase<ValidadorPermisoAccion>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new ValidadorPermisoAccion();
        }


        public class ElMetodo_PermiteModificarDatosPersonaCargo : ValidadorPermisoAccionTest
        {
            private Mock<AsignacionCuidado> asignacionCuidado;
            private Mock<Usuario> usuarioModificador;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.asignacionCuidado = new Mock<AsignacionCuidado>();
                this.asignacionCuidado.Setup(s => s.Colaborador).Returns(Mock.Of<Persona>(p => p.ID == 1));
                this.asignacionCuidado.Setup(s => s.Rol).Returns(Mock.Of<RolCuidado>(r => r.ID == RolesCuidado.Responsable));

                this.usuarioModificador = new Mock<Usuario>();
                this.usuarioModificador.Setup(s => s.Persona).Returns(Mock.Of<Persona>(p => p.ID == 1));
            }

            private bool Action()
            {
                return this.Target.PermiteModificarDatosPersonaCargo(this.asignacionCuidado.Object,
                                                                     this.usuarioModificador.Object);
            }

            [Fact]
            public void Si_el_colaborador_de_la_asignacion_es_diferente_a_la_persona_del_usuario_modificador_devuelve_false()
            {
                // Arrange
                this.usuarioModificador.Setup(s => s.Persona).Returns(Mock.Of<Persona>(p => p.ID == 99));

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Si_el_rol_de_la_asignacion_es_diferente_a_responsable_devuelve_false()
            {
                // Arrange
                this.asignacionCuidado.Setup(s => s.Rol).Returns(Mock.Of<RolCuidado>(r => r.ID == RolesCuidado.Cuidador));

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void En_cualquier_otro_caso_retorna_true()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.True(resultado);
            }
        }
    }
}
