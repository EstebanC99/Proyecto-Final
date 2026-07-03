using CareWell.BusinessService.General;
using CareWell.Repository.General;
using Moq;

namespace CareWell.BusinessService.Test.General
{
    public class AdministrarTipoEventoBusinessTest : BusinessTestClassBase<AdministrarTipoEventoBusinessService>
    {
        private Mock<ITipoEventoRepository> tipoEventoRepository;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.tipoEventoRepository = new Mock<ITipoEventoRepository>();

            this.Target = new AdministrarTipoEventoBusinessService(this.unitOfWork.Object,
                                                                   this.tipoEventoRepository.Object);
        }

        public class ElMetodo_ObtenerTodos : AdministrarTipoEventoBusinessTest
        {
            private void Action()
            {
                this.Target.ObtenerTodos();
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ObtenerTodos_del_TipoEventoRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.tipoEventoRepository.Verify(v => v.ObtenerTodos(), Times.Once);
            }
        }
    }
}
