using CareWell.BusinessService.Auth;
using CareWell.Commands.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.Factories;
using CareWell.Domain.ValueObjects.Auth;
using CareWell.Global.Enumeraciones.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using CareWell.Repository.Auth;
using CareWell.Security;
using Moq;

namespace CareWell.BusinessService.Test.Auth
{
    public class AdministrarDispositivoBusinessTest : BusinessTestClassBase<AdministrarDispositivoBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IUsuarioRepository> usuarioRepository;
        private Mock<IDispositivoUsuarioRepository> dispositivoUsuarioRepository;
        private Mock<IBaseFactory> baseFactory;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.usuarioRepository = new Mock<IUsuarioRepository>();
            this.dispositivoUsuarioRepository = new Mock<IDispositivoUsuarioRepository>();
            this.baseFactory = new Mock<IBaseFactory>();

            this.Target = new AdministrarDispositivoBusinessService
            (
                this.unitOfWork.Object,
                this.userContext.Object,
                this.usuarioRepository.Object,
                this.dispositivoUsuarioRepository.Object,
                this.baseFactory.Object
            );
        }

        public class ElMetodo_Registrar : AdministrarDispositivoBusinessTest
        {
            private RegistrarDispositivoCommand command;

            private Mock<Usuario> usuario;
            private Mock<DispositivoUsuario> dispositivo;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<RegistrarDispositivoCommand>(c => c.Token == "token123" && c.Plataforma == (int)DispositivoPlataformasEnum.Android);

                this.usuario = new Mock<Usuario>();

                this.dispositivo = new Mock<DispositivoUsuario>();

                this.usuarioRepository.Setup(s => s.GetByID(It.IsAny<int>())).Returns(this.usuario.Object);

                this.baseFactory.Setup(s => s.Crear<DispositivoUsuario>()).Returns(this.dispositivo.Object);
            }

            private void Action()
            {
                this.Target.Registrar(this.command);
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
            public void Llama_una_vez_al_metodo_GetByID_del_UsuarioRepository()
            {
                // Arrange
                this.userContext.Setup(s => s.UsuarioID).Returns(1);

                // Action
                this.Action();

                // Assert
                this.usuarioRepository.Verify(v => v.GetByID(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByToken_del_DispositivoUsuarioRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.dispositivoUsuarioRepository.Verify(v => v.GetByToken(this.command.Token), Times.Once);
            }

            [Fact]
            public void Si_no_encuentra_dispositivo_llama_una_vez_al_metodo_Crear_DispositivoUsuario_de_la_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<DispositivoUsuario>(), Times.Once);
            }

            [Fact]
            public void Si_no_encuentra_dispositivo_llama_una_vez_al_metodo_Registrar_del_DispositivoUsuario()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.dispositivo.Verify(v => v.Registrar(It.Is<RegistrarDispositivo>(r =>
                    r.Usuario == this.usuario.Object &&
                    r.Token == this.command.Token &&
                    r.Plataforma == (DispositivoPlataformasEnum)this.command.Plataforma
                )), Times.Once);
            }

            [Fact]
            public void Si_no_encuentra_dispositivo_llama_una_vez_al_metodo_Add_del_DispositivoUsuarioRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.dispositivoUsuarioRepository.Verify(v => v.Add(this.dispositivo.Object), Times.Once);
            }

            [Fact]
            public void Si_encuentra_dispositivo_llama_una_vez_al_metodo_Reasignar_del_DispositivoUsuario()
            {
                // Arrange
                this.dispositivoUsuarioRepository.Setup(s => s.GetByToken(this.command.Token)).Returns(this.dispositivo.Object);

                // Action
                this.Action();

                // Assert
                this.dispositivo.Verify(v => v.RegistrarUso(this.usuario.Object), Times.Once);
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

        public class ElMetodo_Eliminar : AdministrarDispositivoBusinessTest
        {
            private EliminarDispositivoCommand command;

            private Mock<Usuario> usuario;
            private Mock<DispositivoUsuario> dispositivo;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<EliminarDispositivoCommand>(c => c.Token == "token123");

                this.usuario = new Mock<Usuario>();

                this.dispositivo = new Mock<DispositivoUsuario>();
                this.dispositivo.Setup(s => s.PerteneceA(this.usuario.Object)).Returns(true);

                this.usuarioRepository.Setup(s => s.GetByID(It.IsAny<int>())).Returns(this.usuario.Object);

                this.dispositivoUsuarioRepository.Setup(s => s.GetByToken(this.command.Token)).Returns(this.dispositivo.Object);
            }

            private void Action()
            {
                this.Target.Eliminar(this.command);
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
            public void Llama_una_vez_al_metodo_GetByID_del_UsuarioRepository()
            {
                // Arrange
                this.userContext.Setup(s => s.UsuarioID).Returns(1);

                // Action
                this.Action();

                // Assert
                this.usuarioRepository.Verify(v => v.GetByID(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByToken_del_DispositivoUsuarioRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.dispositivoUsuarioRepository.Verify(v => v.GetByToken(this.command.Token), Times.Once);
            }

            [Fact]
            public void Si_no_encuentra_dispositivo_arroja_un_RecursoNoEncontradoException_con_mensaje_informativo()
            {
                // Arrange
                this.dispositivoUsuarioRepository.Setup(s => s.GetByToken(this.command.Token)).Returns((DispositivoUsuario?)null);

                // Action & Assert
                var excepcion = Assert.Throws<RecursoNoEncontradoException>(() => this.Action());
                Assert.Equal(Mensajes.DispositivoNoExiste, excepcion.Message);
            }

            [Fact]
            public void Si_el_dispositivo_no_pertenece_al_usuario_arroja_un_UnauthorizedAccessException_con_mensaje_informativo()
            {
                // Arrange
                this.dispositivo.Setup(s => s.PerteneceA(It.IsAny<Usuario>())).Returns(false);

                // Action & Assert
                var excepcion = Assert.Throws<UnauthorizedAccessException>(() => this.Action());
                Assert.Equal(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion, excepcion.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Desactivar_del_DispositivoUsuario()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.dispositivo.Verify(v => v.Desactivar(), Times.Once);
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

        public class ElMetodo_DesactivarTodosDelUsuario : AdministrarDispositivoBusinessTest
        {
            private Mock<Usuario> usuario;
            private Mock<DispositivoUsuario> dispositivo;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.usuario = new Mock<Usuario>();

                this.dispositivo = new Mock<DispositivoUsuario>();

                this.dispositivoUsuarioRepository.Setup(s => s.GetActivosPorUsuario(this.usuario.Object)).Returns(new List<DispositivoUsuario> { this.dispositivo.Object });
            }

            private void Action()
            {
                this.Target.DesactivarTodosDelUsuario(this.usuario.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetActivosPorUsuario_del_DispositivoUsuarioRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.dispositivoUsuarioRepository.Verify(v => v.GetActivosPorUsuario(this.usuario.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Desactivar_de_cada_Dispositivo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.dispositivo.Verify(v => v.Desactivar(), Times.Once);
            }
        }
    }
}
