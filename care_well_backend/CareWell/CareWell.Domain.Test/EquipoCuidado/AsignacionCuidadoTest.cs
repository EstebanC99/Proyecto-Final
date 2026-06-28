using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
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

        public class ElMetodo_Asignar : AsignacionCuidadoTest
        {
            private CrearAsignacion crearAsignacion;
            private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.crearAsignacion = new CrearAsignacion(
                    Mock.Of<Persona>(),
                    Mock.Of<Persona>(),
                    Mock.Of<Persona>(),
                    Mock.Of<RolCuidado>(),
                    new List<PermisoCuidado> { Mock.Of<PermisoCuidado>() }
                );

                this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
                this.validadorPermisoAccion.Setup(s => s.PermiteAdministrarEquipoCuidado(It.IsAny<Persona>(), It.IsAny<Persona>())).Returns(true);
            }

            private void Action()
            {
                this.Target.Asignar(this.crearAsignacion,
                                    this.entityLoaderDomainService.Object,
                                    this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_PermiteAdministrarEquipoCuidado_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.PermiteAdministrarEquipoCuidado(this.crearAsignacion.PersonaCuidada,
                                                                                          this.crearAsignacion.Asignador), Times.Once);
            }

            [Fact]
            public void Si_el_ValidadorPermisoAccion_devuelve_false_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.validadorPermisoAccion.Setup(s => s.PermiteAdministrarEquipoCuidado(It.IsAny<Persona>(), It.IsAny<Persona>())).Returns(false);

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_PersonaCuidada_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearAsignacion = new CrearAsignacion(
                    null,
                    Mock.Of<Persona>(),
                    Mock.Of<Persona>(),
                    Mock.Of<RolCuidado>(),
                    new List<PermisoCuidado> { Mock.Of<PermisoCuidado>() }
                );

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.PersonaNoExiste, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Colaborador_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearAsignacion = new CrearAsignacion(
                    Mock.Of<Persona>(),
                    null,
                    Mock.Of<Persona>(),
                    Mock.Of<RolCuidado>(),
                    new List<PermisoCuidado> { Mock.Of<PermisoCuidado>() }
                );

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.PersonaColaboradorRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_Rol_es_null_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearAsignacion = new CrearAsignacion(
                    Mock.Of<Persona>(),
                    Mock.Of<Persona>(),
                    Mock.Of<Persona>(),
                    null,
                    new List<PermisoCuidado> { Mock.Of<PermisoCuidado>() }
                );

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.RolCuidadoRequerido, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_no_se_informaron_PermisosCuidado_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearAsignacion = new CrearAsignacion(
                    Mock.Of<Persona>(),
                    Mock.Of<Persona>(),
                    Mock.Of<Persona>(),
                    Mock.Of<RolCuidado>(),
                    new List<PermisoCuidado>()
                );

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.DebeSeleccionarUnoMasPermisos, excepcionEsperada.Message);
            }

            [Fact]
            public void Setea_la_propiedad_PersonaCuidada()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearAsignacion.PersonaCuidada, this.Target.PersonaCuidada);
            }

            [Fact]
            public void Setea_la_propiedad_Colaborador()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearAsignacion.Colaborador, this.Target.Colaborador);
            }

            [Fact]
            public void Setea_la_propiedad_Rol()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearAsignacion.Rol, this.Target.Rol);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_EstadoCuidado_del_EntityLoaderDomainService_con_el_estado_Pendiente()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Pendiente), Times.Once);
            }

            [Fact]
            public void Setea_la_propiedad_Estado()
            {
                // Arrange
                var estadoPendiente = Mock.Of<EstadoAsignacionCuidado>(r => r.ID == EstadosAsignacionCuidado.Pendiente);
                this.entityLoaderDomainService.Setup(s => s.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Pendiente)).Returns(estadoPendiente);

                // Action
                this.Action();

                // Assert
                Assert.Same(estadoPendiente, this.Target.Estado);
            }

            [Fact]
            public void Setea_la_propiedad_FechaAlta()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(DateTime.Now.Date, this.Target.FechaAlta.Date);
            }

            [Fact]
            public void Setea_la_lista_de_Permisos()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equivalent(this.crearAsignacion.Permisos, this.Target.Permisos);
            }
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
                Assert.Equal(DateTime.Now.Date, this.Target.FechaAlta.Date);
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

        public class ElMetodo_ModificarInformacionPersona : AsignacionCuidadoTest
        {
            private ModificarInformacionPersona modificarInformacionPersona;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.modificarInformacionPersona = new ModificarInformacionPersona(
                    It.IsAny<string>(),
                    It.IsAny<string>(),
                    It.IsAny<string>(),
                    It.IsAny<DateTime>(),
                    It.IsAny<string>(),
                    It.IsAny<string>(),
                    Mock.Of<Usuario>()
                );

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
                this.validadorPermisoAccion.Setup(s => s.PermiteModificarDatosPersonaCargo(It.IsAny<AsignacionCuidado>(), It.IsAny<Usuario>())).Returns(true);

                #region AsignarResponsable

                var crearAsignacionResponsable = new CrearAsignacionResponsable(
                    Mock.Of<Persona>(),
                    Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>())
                );

                var entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
                entityLoaderDomainService.Setup(s => s.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Activa)).Returns(Mock.Of<EstadoAsignacionCuidado>(e => e.ID == EstadosAsignacionCuidado.Activa));

                this.Target.AsignarResponsable(crearAsignacionResponsable,
                                               entityLoaderDomainService.Object);

                #endregion
            }

            private void Action()
            {
                this.Target.ModificarInformacionPersona(this.modificarInformacionPersona,
                                                        this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Si_el_Estado_de_la_asignacion_es_diferente_a_Activa_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                var entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
                entityLoaderDomainService.Setup(s => s.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Inactiva)).Returns(Mock.Of<EstadoAsignacionCuidado>(e => e.ID == EstadosAsignacionCuidado.Inactiva));
                this.Target.Eliminar(entityLoaderDomainService.Object);

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.EstadoAsignacionNoPermiteEjecutarAccion, excepcionEsperada.Message);
            }

            [Fact]
            public void Si_el_ValidadorPermisoAccion_devuelve_false_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.validadorPermisoAccion.Setup(s => s.PermiteModificarDatosPersonaCargo(this.Target, this.modificarInformacionPersona.UsuarioModificador)).Returns(false);

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion, excepcionEsperada.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_PermiteModificarDatosPersonaCargo_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.PermiteModificarDatosPersonaCargo(this.Target, this.modificarInformacionPersona.UsuarioModificador), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_CrearModificar_de_la_PersonaCuidada()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Mock.Get(this.Target.PersonaCuidada).Verify(v => v.CrearModificar(this.modificarInformacionPersona), Times.Once);
            }
        }

        public class ElMetodo_Eliminar : AsignacionCuidadoTest
        {
            private Mock<IEntityLoaderDomainService> entityLoaderDomainService;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            }

            private void Action()
            {
                this.Target.Eliminar(this.entityLoaderDomainService.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_EstadoAsignacionCuidado_del_EntityLoaderDomainService_con_el_estado_Inactiva()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Inactiva), Times.Once);
            }

            [Fact]
            public void Setea_la_propiedad_Estado()
            {
                // Arrange
                var estadoCuidado = Mock.Of<EstadoAsignacionCuidado>(r => r.ID == EstadosAsignacionCuidado.Inactiva);
                this.entityLoaderDomainService.Setup(s => s.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Inactiva)).Returns(estadoCuidado);

                // Action
                this.Action();

                // Assert
                Assert.Same(estadoCuidado, this.Target.Estado);
            }

            [Fact]
            public void Setea_la_propiedad_FechaEliminacion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(DateTime.Now.Date, this.Target.FechaEliminacion!.Value.Date);
            }
        }

        public class ElMetodo_Activar : AsignacionCuidadoTest
        {
            private Mock<IEntityLoaderDomainService> entityLoaderDomainService;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();

                #region Asignar

                this.entityLoaderDomainService.Setup(s => s.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Pendiente)).Returns(Mock.Of<EstadoAsignacionCuidado>(e => e.ID == EstadosAsignacionCuidado.Pendiente));

                var crearAsignacion = new CrearAsignacion(
                    Mock.Of<Persona>(),
                    Mock.Of<Persona>(),
                    Mock.Of<Persona>(),
                    Mock.Of<RolCuidado>(),
                    new List<PermisoCuidado> { Mock.Of<PermisoCuidado>() }
                );

                var validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
                validadorPermisoAccion.Setup(s => s.PermiteAdministrarEquipoCuidado(It.IsAny<Persona>(), It.IsAny<Persona>())).Returns(true);

                this.Target.Asignar(crearAsignacion,
                                    this.entityLoaderDomainService.Object,
                                    validadorPermisoAccion.Object);

                #endregion
            }

            private void Action()
            {
                this.Target.Activar(this.entityLoaderDomainService.Object);
            }

            [Fact]
            public void Si_el_estado_de_la_asignacion_es_diferente_de_Pendiente_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.entityLoaderDomainService.Setup(s => s.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Inactiva)).Returns(Mock.Of<EstadoAsignacionCuidado>(e => e.ID == EstadosAsignacionCuidado.Inactiva));

                this.Target = new AsignacionCuidado();
                this.Target.Eliminar(this.entityLoaderDomainService.Object);

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NoSePuedeActivarUnaAsignacionConEstadoDiferentePendiente, excepcionEsperada.Message);
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
        }

        public class ElMetodo_Reactivar : AsignacionCuidadoTest
        {
            private Mock<IEntityLoaderDomainService> entityLoaderDomainService;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();

                this.Target.Eliminar(this.entityLoaderDomainService.Object);
            }

            private void Action()
            {
                this.Target.Reactivar(this.entityLoaderDomainService.Object);
            }

            private class AsignacionCuidadoTestClass : AsignacionCuidado
            {
                public override DateTime? FechaEliminacion { get => DateTime.Now.AddDays(-31); }
            }

            [Fact]
            public void Si_no_tiene_fecha_de_eliminacion_no_llama_nunca_al_metodo_GetByID_EstadoAsignacionCuidado_del_EntityLoaderDomainService()
            {
                // Arrange
                this.Target = new AsignacionCuidado();

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Activa), Times.Never);
            }

            [Fact]
            public void Si_la_FechaEliminacion_supera_los_30_dias_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.Target = new AsignacionCuidadoTestClass();

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.NoPuedeReactivarUnaAsignacionPasadoLos30Dias, excepcionEsperada.Message);
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
            public void Setea_la_propiedad_FechaEliminacion_en_null()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Null(this.Target.FechaEliminacion);
            }
        }

        public class ElMetodo_ModificarPermisos : AsignacionCuidadoTest
        {
            private ModificarPermisosAsignacion modificarPermisos;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.modificarPermisos = new ModificarPermisosAsignacion(
                    Asignador: Mock.Of<Persona>(),
                    NuevosPermisos: new List<PermisoCuidado> { Mock.Of<PermisoCuidado>(p => p.ID == PermisosCuidado.GestionarAgenda) }
                );

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
                this.validadorPermisoAccion.Setup(s => s.PermiteAdministrarEquipoCuidado(It.IsAny<Persona>(), It.IsAny<Persona>())).Returns(true);

                #region AsignarResponsable

                var crearAsignacionResponsable = new CrearAsignacionResponsable(
                    Mock.Of<Persona>(),
                    Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>())
                );

                var entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
                entityLoaderDomainService.Setup(s => s.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Activa)).Returns(Mock.Of<EstadoAsignacionCuidado>(e => e.ID == EstadosAsignacionCuidado.Activa));

                this.Target.AsignarResponsable(crearAsignacionResponsable,
                                               entityLoaderDomainService.Object);

                #endregion
            }

            private void Action()
            {
                this.Target.ModificarPermisos(this.modificarPermisos,
                                              this.validadorPermisoAccion.Object);
            }

            [Fact]
            public void Si_el_estado_no_es_Activa_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                var entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
                entityLoaderDomainService.Setup(s => s.GetByID<EstadoAsignacionCuidado>(EstadosAsignacionCuidado.Inactiva)).Returns(Mock.Of<EstadoAsignacionCuidado>(e => e.ID == EstadosAsignacionCuidado.Inactiva));

                this.Target.Eliminar(entityLoaderDomainService.Object);

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.EstadoAsignacionNoPermiteEjecutarAccion, excepcionEsperada.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_PermiteModificarDatosPersonaCargo_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.PermiteAdministrarEquipoCuidado(this.Target.PersonaCuidada, this.modificarPermisos.Asignador), Times.Once);
            }

            [Fact]
            public void Si_el_ValidadorPermisoAccion_devuelve_false_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.validadorPermisoAccion.Setup(s => s.PermiteAdministrarEquipoCuidado(this.Target.PersonaCuidada, this.modificarPermisos.Asignador)).Returns(false);

                // Action & Assert
                var excepcionEsperada = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion, excepcionEsperada.Message);
            }

            [Fact]
            public void Agrega_los_permisos_que_no_existian_a_la_lista_de_Permisos()
            {
                // Arrange
                this.Target.Permisos.Clear();

                // Action
                this.Action();

                // Assert
                Assert.Equivalent(this.modificarPermisos.NuevosPermisos, this.Target.Permisos);
            }

            [Fact]
            public void Elimina_los_permisos_que_no_se_seleccionaron_de_la_lista_de_Permisos()
            {
                // Arrange
                this.Target.Permisos.Add(Mock.Of<PermisoCuidado>(p => p.ID == PermisosCuidado.ActivarEmergencia));

                // Action
                this.Action();

                // Assert
                Assert.Equivalent(this.modificarPermisos.NuevosPermisos, this.Target.Permisos);
            }
        }
    }
}
