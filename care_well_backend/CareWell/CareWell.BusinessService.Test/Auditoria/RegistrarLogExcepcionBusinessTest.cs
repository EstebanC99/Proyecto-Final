using CareWell.BusinessService.Auditoria;
using CareWell.Commands.Auditoria;
using CareWell.Domain.Auditoria;
using CareWell.Domain.Factories;
using CareWell.Domain.ValueObjects.Auditoria;
using CareWell.Repository.Auditoria;
using Microsoft.Extensions.Logging;
using Moq;

namespace CareWell.BusinessService.Test.Auditoria
{
    public class RegistrarLogExcepcionBusinessTest : BusinessTestClassBase<RegistrarLogExcepcionBusinessService>
    {
        private Mock<ILogUnitOfWork> logUnitOfWork;
        private Mock<ILogExcepcionRepository> logExcepcionRepository;
        private Mock<IBaseFactory> baseFactory;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.logUnitOfWork = new Mock<ILogUnitOfWork>();
            this.logExcepcionRepository = new Mock<ILogExcepcionRepository>();
            this.baseFactory = new Mock<IBaseFactory>();

            this.Target = new RegistrarLogExcepcionBusinessService
            (
                this.logUnitOfWork.Object,
                this.logExcepcionRepository.Object,
                this.baseFactory.Object,
                Mock.Of<ILogger<RegistrarLogExcepcionBusinessService>>()
            );
        }

        public class ElMetodo_Registrar : RegistrarLogExcepcionBusinessTest
        {
            private RegistrarLogExcepcionCommand command;
            private Mock<LogExcepcion> logExcepcion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = new RegistrarLogExcepcionCommand
                {
                    Tipo = "Tipo X",
                    Controlada = true,
                    Mensaje = "Mensaje Error",
                    StackTrace = "Stacktrace X",
                    Ruta = "Ruta ASD",
                    Verbo = "POST",
                    TraceIdentifier = "Traza 123",
                    UsuarioID = 1
                };

                this.logExcepcion = new Mock<LogExcepcion>();

                this.baseFactory.Setup(s => s.Crear<LogExcepcion>()).Returns(this.logExcepcion.Object);
            }

            private void Action()
            {
                this.Target.Registrar(this.command);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_LogExcepcion_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<LogExcepcion>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Registrar_del_LogExcepcion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.logExcepcion.Verify(v => v.Registrar(It.Is<RegistrarLogExcepcion>(r =>
                    r.Tipo == this.command.Tipo &&
                    r.Controlada == this.command.Controlada &&
                    r.Mensaje == this.command.Mensaje &&
                    r.StackTrace == this.command.StackTrace &&
                    r.Ruta == this.command.Ruta &&
                    r.Verbo == this.command.Verbo &&
                    r.TraceIdentifier == this.command.TraceIdentifier &&
                    r.UsuarioID == this.command.UsuarioID
                )), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_LogExcepcionRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.logExcepcionRepository.Verify(v => v.Add(this.logExcepcion.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_LogUnitOfWork()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.logUnitOfWork.Verify(v => v.SaveChanges(), Times.Once);
            }

            [Fact]
            public void Si_se_produce_alguna_excepcion_no_la_arroja()
            {
                // Arrange
                this.logExcepcion.Setup(s => s.Registrar(It.IsAny<RegistrarLogExcepcion>())).Throws(new Exception());

                // Action
                var excepcion = Record.Exception(() => this.Action());

                // Assert
                Assert.Null(excepcion);
            }
        }
    }
}
