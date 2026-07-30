using CareWell.BusinessService.Salud;
using CareWell.Repository.Salud;
using Moq;

namespace CareWell.BusinessService.Test.Salud
{
    public class AdministrarTipoHabitoVidaBusinessTest : BusinessTestClassBase<AdministrarTipoHabitoVidaBusinessService>
    {
        private Mock<ITipoHabitoVidaRepository> tipoHabitoVidaRepository;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.tipoHabitoVidaRepository = new Mock<ITipoHabitoVidaRepository>();

            this.Target = new AdministrarTipoHabitoVidaBusinessService(this.unitOfWork.Object,
                                                                       this.tipoHabitoVidaRepository.Object);
        }

        public class ElMetodo_ObtenerTodos : AdministrarTipoHabitoVidaBusinessTest
        {
            private void Action()
            {
                this.Target.ObtenerTodos();
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ObtenerTodos_del_TipoHabitoVidaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.tipoHabitoVidaRepository.Verify(v => v.ObtenerTodos(), Times.Once);
            }
        }
    }
}
