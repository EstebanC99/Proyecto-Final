using CareWell.Domain.DomainServices;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Global.Constantes.EquipoCuidado;
using Moq;

namespace CareWell.Domain.Test.Validadores
{
    public class ValidarExistenciaAsignacionCuidadoTest : TestClassBase<ValidarExistenciaAsignacionCuidado>
    {
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();

            this.Target = new ValidarExistenciaAsignacionCuidado(
                this.entityLoaderDomainService.Object
            );
        }

        public class ElMetodo_ExisteAsignacionColaboradorElegido : ValidarExistenciaAsignacionCuidadoTest
        {
            private Persona personaCuidada;
            private Persona colaborador;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.personaCuidada = Mock.Of<Persona>(p => p.ID == 1);
                this.colaborador = Mock.Of<Persona>(p => p.ID == 2);

                this.entityLoaderDomainService.Setup(s => s.Query<AsignacionCuidado>()).Returns(new List<AsignacionCuidado>().AsQueryable);
            }

            private bool Action()
            {
                return this.Target.ExisteAsignacionColaboradorElegido(this.personaCuidada, this.colaborador);
            }

            [Fact]
            public void Retorna_false_si_la_persona_cuidada_es_null()
            {
                // Arrange
                this.personaCuidada = null;

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Retorna_false_si_el_colaborador_es_null()
            {
                // Arrange
                this.colaborador = null;

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Retorna_true_si_existe_una_asignacion_de_cuidado_para_la_persona_y_colaborador_seleccionados_en_estado_activa()
            {
                // Arrange
                var asignacionCuidado = Mock.Of<AsignacionCuidado>(a =>
                    a.PersonaCuidada == this.personaCuidada &&
                    a.Colaborador == this.colaborador &&
                    a.Estado == Mock.Of<EstadoAsignacionCuidado>(e => e.ID == EstadosAsignacionCuidado.Activa)
                );
                this.entityLoaderDomainService.Setup(s => s.Query<AsignacionCuidado>()).Returns(new List<AsignacionCuidado> { asignacionCuidado }.AsQueryable);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.True(resultado);
            }

            [Fact]
            public void Retorna_true_si_existe_una_asignacion_de_cuidado_para_la_persona_y_colaborador_seleccionados_en_estado_pendiente()
            {
                // Arrange
                var asignacionCuidado = Mock.Of<AsignacionCuidado>(a =>
                    a.PersonaCuidada == this.personaCuidada &&
                    a.Colaborador == this.colaborador &&
                    a.Estado == Mock.Of<EstadoAsignacionCuidado>(e => e.ID == EstadosAsignacionCuidado.Activa)
                );
                this.entityLoaderDomainService.Setup(s => s.Query<AsignacionCuidado>()).Returns(new List<AsignacionCuidado> { asignacionCuidado }.AsQueryable);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.True(resultado);
            }

            [Fact]
            public void Retorna_false_en_cualquier_otro_caso()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Retorna_siempre_un_bool()
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
