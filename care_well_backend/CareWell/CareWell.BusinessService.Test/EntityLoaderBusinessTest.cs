using CareWell.Domain;
using CareWell.Repository;
using Moq;

namespace CareWell.BusinessService.Test
{
    public class EntityLoaderBusinessTest : BusinessTestClassBase<EntityLoaderBusinessService>
    {
        private Mock<IEntityLoaderRepository> entityLoaderRepository;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.entityLoaderRepository = new Mock<IEntityLoaderRepository>();

            this.Target = new EntityLoaderBusinessService(this.entityLoaderRepository.Object);
        }

        public class ElMetodo_GetByID : EntityLoaderBusinessTest
        {
            private class BaseEntityTestClass : BaseEntity { }
            private readonly int id = 1;

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_del_Repository()
            {
                // Arrange

                // Action
                this.Target.GetByID<BaseEntityTestClass>(this.id);

                // Assert
                this.entityLoaderRepository.Verify(v => v.GetByID<BaseEntityTestClass>(this.id), Times.Once);
            }
        }

        public class ElMetodo_Query : EntityLoaderBusinessTest
        {
            private class BaseEntityTestClass : BaseEntity { }

            [Fact]
            public void Llama_una_vez_al_metodo_Query_del_Repository()
            {
                // Arrange

                // Action
                this.Target.Query<BaseEntityTestClass>();

                // Assert
                this.entityLoaderRepository.Verify(v => v.Query<BaseEntityTestClass>(), Times.Once);
            }
        }
    }
}
