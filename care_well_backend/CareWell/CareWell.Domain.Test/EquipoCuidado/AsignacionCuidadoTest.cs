using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;
using CareWell.Domain.ValueObjects.EquipoCuidado;
using CareWell.Global.Constantes.EquipoCuidado;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.EquipoCuidado
{
    public class AsignacionCuidadoTest : TestClassBase<AsignacionCuidado>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new AsignacionCuidado();
        }

        public class ElMetodo_AsignarResponsable : AsignacionCuidadoTest
        {
            private CrearAsignacionResponsable crearAsignacionResponsable;
            private Mock<IEntityLoaderDomainService> entityLoaderDomainService;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.crearAsignacionResponsable = new CrearAsignacionResponsable(
                    Mock.Of<Persona>(),
                    Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>())
                );

                this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            }

            private void Action()
            {
                this.Target.AsignarResponsable(this.crearAsignacionResponsable,
                                               this.entityLoaderDomainService.Object);
            }

            [Fact]
            public void Si_PersonaCuidada_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearAsignacionResponsable = new CrearAsignacionResponsable(
                    null,
                    Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>())
                );

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.PersonaNoExiste, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Usuario_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearAsignacionResponsable = new CrearAsignacionResponsable(
                    Mock.Of<Persona>(),
                    null
                );

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ColaboradorRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Persona_del_Usuario_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearAsignacionResponsable = new CrearAsignacionResponsable(
                    Mock.Of<Persona>(),
                    Mock.Of<Usuario>()
                );

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ColaboradorRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Setea_la_propiedad_PersonaCuidada()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearAsignacionResponsable.PersonaCuidada, this.Target.PersonaCuidada);
            }

            [Fact]
            public void Setea_la_propiedad_Colaborador()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearAsignacionResponsable.UsuarioCreador.Persona, this.Target.Colaborador);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_RolCuidado_del_EntityLoaderDomainService_con_el_rol_Responsable()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<RolCuidado>(RolesCuidado.Responsable), Times.Once);
            }

            [Fact]
            public void Setea_la_propiedad_Rol()
            {
                // Arrange
                var rolResponsable = Mock.Of<RolCuidado>(r => r.ID == RolesCuidado.Responsable);
                this.entityLoaderDomainService.Setup(s => s.GetByID<RolCuidado>(RolesCuidado.Responsable)).Returns(rolResponsable);

                // Action
                this.Action();

                // Assert
                Assert.Same(rolResponsable, this.Target.Rol);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_EstadoAsignacionCuidado_del_EntityLoaderDomainService_con_el_estado_Activa()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Activa), Times.Once);
            }

            [Fact]
            public void Setea_la_propiedad_Estado()
            {
                // Arrange
                var estadoCuidado = Mock.Of<EstadoAsignacionCuidado>(r => r.ID == EstadosAsignacionCuidado.Activa);
                this.entityLoaderDomainService.Setup(s => s.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Activa)).Returns(estadoCuidado);

                // Action
                this.Action();

                // Assert
                Assert.Same(estadoCuidado, this.Target.Estado);
            }

            [Fact]
            public void Setea_la_propiedad_FechaAlta()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(DateTime.UtcNow.Date, this.Target.FechaAlta.Date);
            }
        }

        public class ElMetodo_AsignarPermisosResponsable : AsignacionCuidadoTest
        {
            private Mock<IEntityLoaderDomainService> entityLoaderDomainService;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            }

            private void Action()
            {
                this.Target.AsignarPermisosResponsable(this.entityLoaderDomainService.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Query_PermisoCuidado_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.Query<PermisoCuidado>(), Times.Once);
            }

            [Fact]
            public void Setea_la_lista_de_Permisos_devuelta_por_el_EntityLoaderDomainService()
            {
                // Arrange
                var permisos = new List<PermisoCuidado>
                {
                    Mock.Of<PermisoCuidado>(p => p.ID == PermisosCuidado.GestionarAgenda),
                    Mock.Of<PermisoCuidado>(p => p.ID == PermisosCuidado.RegistrarHabitos)
                };
                this.entityLoaderDomainService.Setup(s => s.Query<PermisoCuidado>()).Returns(permisos.AsQueryable);

                // Action
                this.Action();

                // Assert
                Assert.Equivalent(permisos, this.Target.Permisos);
            }
        }
    }
}
