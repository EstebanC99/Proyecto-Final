using CareWell.BusinessService.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Repository.Auth;
using CareWell.Security;
using Moq;

namespace CareWell.BusinessService.Test.Auth
{
    public class EliminarCuentaBusinessTest : BusinessTestClassBase<EliminarCuentaBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IUsuarioRepository> usuarioRepository;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IAdministrarDispositivoDomainService> administrarDispositivoDomainService;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.usuarioRepository = new Mock<IUsuarioRepository>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.administrarDispositivoDomainService = new Mock<IAdministrarDispositivoDomainService>();

            this.Target = new EliminarCuentaBusinessService
            (
                this.unitOfWork.Object,
                this.userContext.Object,
                this.usuarioRepository.Object,
                this.entityLoaderDomainService.Object,
                this.administrarDispositivoDomainService.Object
            );
        }

        public class ElMetodo_Eliminar : EliminarCuentaBusinessTest
        {
            private Mock<Usuario> usuario;
            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.usuario = new Mock<Usuario>();
                this.usuario.Setup(s => s.ID).Returns(99);

                this.userContext.Setup(s => s.UsuarioID).Returns(this.usuario.Object.ID);

                this.usuarioRepository.Setup(s => s.GetByID(It.IsAny<int>())).Returns(this.usuario.Object);
            }

            private void Action()
            {
                this.Target.Eliminar();
            }

            [Fact]
            public void Lee_el_UsuarioID_del_UserContext()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.userContext.Verify(v => v.UsuarioID, Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_del_UsuarioRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.usuarioRepository.Verify(v => v.GetByID(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Eliminar_del_Usuario()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.usuario.Verify(v => v.Eliminar(this.entityLoaderDomainService.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_DesactivarTodosDelUsuario_del_AdministrarDispositivoDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.administrarDispositivoDomainService.Verify(v => v.DesactivarTodosDelUsuario(this.usuario.Object), Times.Once);
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
