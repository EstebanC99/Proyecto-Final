using CareWell.BusinessService.Auditoria;
using CareWell.Domain.Auditoria;
using CareWell.Domain.Factories;
using CareWell.Domain.ValueObjects.Auditoria;
using CareWell.Repository.Auditoria;
using Microsoft.Extensions.Logging;
using Moq;

namespace CareWell.BusinessService.Test.Auditoria
{
    public class RegistradorLogServicioExternoBusinessTest : BusinessTestClassBase<RegistradorLogServicioExternoBusinessService>
    {
        private Mock<ILogUnitOfWork> logUnitOfWork;
        private Mock<ILogServicioExternoRepository> logServicioExternoRepository;
        private Mock<IBaseFactory> baseFactory;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.logUnitOfWork = new Mock<ILogUnitOfWork>();
            this.logServicioExternoRepository = new Mock<ILogServicioExternoRepository>();
            this.baseFactory = new Mock<IBaseFactory>();

            this.Target = new RegistradorLogServicioExternoBusinessService
            (
                this.logUnitOfWork.Object,
                this.logServicioExternoRepository.Object,
                this.baseFactory.Object,
                Mock.Of<ILogger<RegistradorLogServicioExternoBusinessService>>()
            );
        }

        public class ElMetodo_Registrar : RegistradorLogServicioExternoBusinessTest
        {
            private const string NombreServicioExterno = "Gemini";
            private const string Request = "Request X";
            private const string Response = "Response X";

            private Mock<LogServicioExterno> logServicioExterno;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.logServicioExterno = new Mock<LogServicioExterno>();

                this.baseFactory.Setup(s => s.Crear<LogServicioExterno>()).Returns(this.logServicioExterno.Object);
            }

            private void Action()
            {
                this.Target.Registrar(NombreServicioExterno, Request, Response);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_LogServicioExterno_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<LogServicioExterno>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Registrar_del_LogServicioExterno()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.logServicioExterno.Verify(v => v.Registrar(It.Is<RegistrarLogServicioExterno>(r =>
                    r.NombreServicioExterno == NombreServicioExterno &&
                    r.Request == Request &&
                    r.Response == Response
                )), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_LogServicioExternoRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.logServicioExternoRepository.Verify(v => v.Add(this.logServicioExterno.Object), Times.Once);
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
                this.logServicioExterno.Setup(s => s.Registrar(It.IsAny<RegistrarLogServicioExterno>())).Throws(new Exception());

                // Action
                var excepcion = Record.Exception(() => this.Action());

                // Assert
                Assert.Null(excepcion);
            }
        }
    }
}
