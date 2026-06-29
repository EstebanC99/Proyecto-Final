using CareWell.BusinessService.EquipoCuidado;
using CareWell.Commands.EquipoCuidado;
using CareWell.DataViews.EquipoCuidado;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.EquipoCuidado;
using CareWell.Queries.EquipoCuidado;
using CareWell.Repository.EquipoCuidado;
using CareWell.Repository.General;
using CareWell.Security;
using Moq;

namespace CareWell.BusinessService.Test.EquipoCuidado
{
    public class AdministrarEquipoCuidadoBusinessTest : BusinessTestClassBase<AdministrarEquipoCuidadoBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
        private Mock<IValidarExistenciaAsignacionCuidado> validarExistenciaAsignacionCuidado;
        private Mock<IPersonaRepository> personaRepository;
        private Mock<IBaseFactory> baseFactory;
        private Mock<IAsignacionCuidadoRepository> asignacionCuidadoRepository;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            this.validarExistenciaAsignacionCuidado = new Mock<IValidarExistenciaAsignacionCuidado>();
            this.personaRepository = new Mock<IPersonaRepository>();
            this.baseFactory = new Mock<IBaseFactory>();
            this.asignacionCuidadoRepository = new Mock<IAsignacionCuidadoRepository>();

            this.Target = new AdministrarEquipoCuidadoBusinessService(this.unitOfWork.Object,
                                                                      this.userContext.Object,
                                                                      this.entityLoaderDomainService.Object,
                                                                      this.validadorPermisoAccion.Object,
                                                                      this.validarExistenciaAsignacionCuidado.Object,
                                                                      this.personaRepository.Object,
                                                                      this.baseFactory.Object,
                                                                      this.asignacionCuidadoRepository.Object);
        }

        public class ElMetodo_ObtenerAsignacionesPorPersonaCuidada : AdministrarEquipoCuidadoBusinessTest
        {
            private AsignacionCuidadoQuery query;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<AsignacionCuidadoQuery>(q => q.PersonaCuidadaID == 1);
            }

            private List<AsignacionCuidadoDataView> Action()
            {
                return this.Target.ObtenerAsignacionesPorPersonaCuidada(this.query);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ObtenerAsignacionesPorPersonaCuidada_del_Repository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidadoRepository.Verify(v => v.ObtenerAsignacionesPorPersonaCuidada(this.query.PersonaCuidadaID), Times.Once);
            }
        }

        public class ElMetodo_Asignar : AdministrarEquipoCuidadoBusinessTest
        {
            private CrearAsignacionCuidadoCommand command;
            private Mock<AsignacionCuidado> asignacionCuidado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<CrearAsignacionCuidadoCommand>(c =>
                    c.PersonaCuidadaID == 1 &&
                    c.ColaboradorEmail == "email@ejemplo" &&
                    c.RolCuidadoID == 2 &&
                    c.PermisosIDs == new List<int> { 3 }
                );

                this.asignacionCuidado = new Mock<AsignacionCuidado>();
                this.asignacionCuidado.Setup(s => s.IsTransient()).Returns(true);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>());

                this.baseFactory.Setup(s => s.Crear<AsignacionCuidado>()).Returns(this.asignacionCuidado.Object);
            }

            private void Action()
            {
                this.Target.Asignar(this.command);
            }

            [Fact]
            public void Lee_una_vez_el_UsuarioID_del_UserContext()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.userContext.Verify(v => v.UsuarioID, Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService_con_el_id_de_usuario_logueado()
            {
                // Arrange
                var usuarioID = 99;
                this.userContext.Setup(s => s.UsuarioID).Returns(usuarioID);

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Usuario>(usuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_del_PersonaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaRepository.Verify(v => v.GetByID(this.command.PersonaCuidadaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByEmail_del_PersonaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.personaRepository.Verify(v => v.GetByEmail(this.command.ColaboradorEmail), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_RolCuidado_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<RolCuidado>(this.command.RolCuidadoID), Times.Once);
            }

            [Fact]
            public void Llama_al_metodo_GetByID_PermisoCuidado_del_EntityLoaderDomainService_tantas_veces_como_permisos_haya()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<PermisoCuidado>(It.Is<int>(p => this.command.PermisosIDs.Contains(p))), Times.Exactly(this.command.PermisosIDs.Count));
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetInactiveByColaborador_de_AsignacionCuidadoRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidadoRepository.Verify(v => v.GetInactiveByColaborador(It.IsAny<Persona>(), It.IsAny<Persona>()), Times.Once);
            }

            [Fact]
            public void Si_no_encuentra_asignacion_inactiva_existente_llama_una_vez_al_metodo_Crear_AsignacionCuidado_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<AsignacionCuidado>(), Times.Once);
            }


            [Fact]
            public void Si_encuentra_asignacion_inactiva_existente_no_llama_nunca_al_metodo_Crear_AsignacionCuidado_del_BaseFactory()
            {
                // Arrange
                this.asignacionCuidadoRepository.Setup(v => v.GetInactiveByColaborador(It.IsAny<Persona>(), It.IsAny<Persona>())).Returns(this.asignacionCuidado.Object);

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<AsignacionCuidado>(), Times.Never);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Asignar_de_la_AsignacionCuidado()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidado.Verify(v => v.Asignar(It.IsAny<CrearAsignacion>(),
                                                             this.entityLoaderDomainService.Object,
                                                             this.validadorPermisoAccion.Object,
                                                             this.validarExistenciaAsignacionCuidado.Object), Times.Once);
            }

            [Fact]
            public void Si_la_asignacion_es_nueva_llama_una_vez_al_metodo_Add_de_AsignacionCuidadoRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidadoRepository.Verify(v => v.Add(this.asignacionCuidado.Object), Times.Once);
            }

            [Fact]
            public void Si_la_asignacion_ya_existia_no_llama_nunca_al_metodo_Add_de_AsignacionCuidadoRepository()
            {
                // Arrange
                this.asignacionCuidado.Setup(s => s.IsTransient()).Returns(false);
                this.asignacionCuidadoRepository.Setup(v => v.GetInactiveByColaborador(It.IsAny<Persona>(), It.IsAny<Persona>())).Returns(this.asignacionCuidado.Object);

                // Action
                this.Action();

                // Assert
                this.asignacionCuidadoRepository.Verify(v => v.Add(It.IsAny<AsignacionCuidado>()), Times.Never);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(v => v.SaveChanges(), Times.Once);
            }
        }

        public class ElMetodo_ModificarPermisos : AdministrarEquipoCuidadoBusinessTest
        {
            private ModificarPermisosAsignacionCommand command;
            private Mock<AsignacionCuidado> asignacionCuidado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<ModificarPermisosAsignacionCommand>(c =>
                    c.AsignacionCuidadoID == 1 &&
                    c.PermisosIDs == new List<int> { 3 }
                );

                this.asignacionCuidado = new Mock<AsignacionCuidado>();

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>());

                this.asignacionCuidadoRepository.Setup(s => s.GetByID(It.IsAny<int>())).Returns(this.asignacionCuidado.Object);
            }

            private void Action()
            {
                this.Target.ModificarPermisos(this.command);
            }

            [Fact]
            public void Lee_una_vez_el_UsuarioID_del_UserContext()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.userContext.Verify(v => v.UsuarioID, Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService_con_el_id_de_usuario_logueado()
            {
                // Arrange
                var usuarioID = 99;
                this.userContext.Setup(s => s.UsuarioID).Returns(usuarioID);

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Usuario>(usuarioID), Times.Once);
            }

            [Fact]
            public void Llama_al_metodo_GetByID_PermisoCuidado_del_EntityLoaderDomainService_tantas_veces_como_permisos_haya()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<PermisoCuidado>(It.Is<int>(p => this.command.PermisosIDs.Contains(p))), Times.Exactly(this.command.PermisosIDs.Count));
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_del_AsignacionCuidadoRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidadoRepository.Verify(v => v.GetByID(this.command.AsignacionCuidadoID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ModificarPermisos_de_la_AsignacionCuidado()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidado.Verify(v => v.ModificarPermisos(It.IsAny<ModificarPermisosAsignacion>(),
                                                                       this.validadorPermisoAccion.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(v => v.SaveChanges(), Times.Once);
            }
        }

        public class ElMetodo_EliminarAsignacion : AdministrarEquipoCuidadoBusinessTest
        {
            private int asignacionCuidadoID;
            private Mock<AsignacionCuidado> asignacionCuidado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.asignacionCuidado = new Mock<AsignacionCuidado>();

                this.asignacionCuidadoID = 1;

                this.asignacionCuidadoRepository.Setup(s => s.GetByID(It.IsAny<int>())).Returns(this.asignacionCuidado.Object);
            }

            private void Action()
            {
                this.Target.EliminarAsignacion(this.asignacionCuidadoID);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usario_del_AsignacionCuidadoRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidadoRepository.Verify(v => v.GetByID(this.asignacionCuidadoID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Eliminar_de_la_AsinacionCuidado()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidado.Verify(v => v.Eliminar(this.entityLoaderDomainService.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(v => v.SaveChanges(), Times.Once);
            }
        }

        public class ElMetodo_ActivarAsignacion : AdministrarEquipoCuidadoBusinessTest
        {
            private int asignacionCuidadoID;
            private Mock<AsignacionCuidado> asignacionCuidado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.asignacionCuidado = new Mock<AsignacionCuidado>();

                this.asignacionCuidadoID = 1;

                this.asignacionCuidadoRepository.Setup(s => s.GetByID(It.IsAny<int>())).Returns(this.asignacionCuidado.Object);
            }

            private void Action()
            {
                this.Target.ActivarAsignacion(this.asignacionCuidadoID);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usario_del_AsignacionCuidadoRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidadoRepository.Verify(v => v.GetByID(this.asignacionCuidadoID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Activar_de_la_AsinacionCuidado()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidado.Verify(v => v.Activar(this.entityLoaderDomainService.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(v => v.SaveChanges(), Times.Once);
            }
        }

        public class ElMetodo_ReactivarAsignacion : AdministrarEquipoCuidadoBusinessTest
        {
            private int asignacionCuidadoID;
            private Mock<Usuario> usuarioReactivador;
            private Mock<AsignacionCuidado> asignacionCuidado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.usuarioReactivador = new Mock<Usuario>();
                this.usuarioReactivador.Setup(s => s.Persona).Returns(Mock.Of<Persona>());

                this.asignacionCuidado = new Mock<AsignacionCuidado>();

                this.asignacionCuidadoID = 1;

                this.asignacionCuidadoRepository.Setup(s => s.GetByID(It.IsAny<int>())).Returns(this.asignacionCuidado.Object);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(this.usuarioReactivador.Object);
            }

            private void Action()
            {
                this.Target.ReactivarAsignacion(this.asignacionCuidadoID);
            }

            [Fact]
            public void Lee_una_vez_el_UsuarioID_del_UserContext()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.userContext.Verify(v => v.UsuarioID, Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService_con_el_id_de_usuario_logueado()
            {
                // Arrange
                var usuarioID = 99;
                this.userContext.Setup(s => s.UsuarioID).Returns(usuarioID);

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Usuario>(usuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usario_del_AsignacionCuidadoRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidadoRepository.Verify(v => v.GetByID(this.asignacionCuidadoID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Reactivar_de_la_AsinacionCuidado()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.asignacionCuidado.Verify(v => v.Reactivar(this.usuarioReactivador.Object.Persona,
                                                               this.entityLoaderDomainService.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(v => v.SaveChanges(), Times.Once);
            }
        }
    }
}
