using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Global.Constantes.EquipoCuidado;
using Moq;

namespace CareWell.Domain.Test.Validadores
{
    public class ValidadorPermisoAccionTest : TestClassBase<ValidadorPermisoAccion>
    {
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();

            this.Target = new ValidadorPermisoAccion(this.entityLoaderDomainService.Object);
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

        public class ElMetodo_PermiteAdministrarEquipoCuidado : ValidadorPermisoAccionTest
        {
            private Mock<Persona> personaCuidada;
            private Mock<Persona> asignador;
            private Mock<AsignacionCuidado> asignacionCuidado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.personaCuidada = new Mock<Persona>();
                this.personaCuidada.Setup(s => s.ID).Returns(1);

                this.asignador = new Mock<Persona>();
                this.asignador.Setup(s => s.ID).Returns(2);

                this.asignacionCuidado = new Mock<AsignacionCuidado>();
                this.asignacionCuidado.Setup(s => s.PersonaCuidada).Returns(this.personaCuidada.Object);
                this.asignacionCuidado.Setup(s => s.Colaborador).Returns(this.asignador.Object);
                this.asignacionCuidado.Setup(s => s.Permisos).Returns(new List<PermisoCuidado> { Mock.Of<PermisoCuidado>(p => p.ID == PermisosCuidado.AdministrarEquipo) });

                this.entityLoaderDomainService.Setup(s => s.Query<AsignacionCuidado>()).Returns(new List<AsignacionCuidado> { this.asignacionCuidado.Object }.AsQueryable);
            }

            private bool Action()
            {
                return this.Target.PermiteAdministrarEquipoCuidado(this.personaCuidada.Object,
                                                                   this.asignador.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Query_AsignacionCuidado_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.Query<AsignacionCuidado>(), Times.Once);
            }

            [Fact]
            public void Si_no_existe_asignacion_cuidado_entre_la_persona_a_cuidar_y_el_asignador_retorna_false()
            {
                // Arrange
                this.entityLoaderDomainService.Setup(s => s.Query<AsignacionCuidado>()).Returns(new List<AsignacionCuidado>().AsQueryable);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Si_en_la_asignacion_cuidado_entre_la_persona_a_cuidar_y_el_asignador_no_tiene_el_permiso_de_administrar_equipo_de_cuidado_retorna_false()
            {
                // Arrange
                this.asignacionCuidado.Setup(s => s.Permisos).Returns(new List<PermisoCuidado> { Mock.Of<PermisoCuidado>(p => p.ID == PermisosCuidado.ActivarEmergencia) });

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
