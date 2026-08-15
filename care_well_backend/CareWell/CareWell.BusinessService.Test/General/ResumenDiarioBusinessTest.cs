using CareWell.BusinessService.Abstractions.General;
using CareWell.BusinessService.General;
using CareWell.DataViews.General;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.General;
using CareWell.Queries.General;
using CareWell.Repository.General;
using CareWell.Security;
using Microsoft.EntityFrameworkCore;
using Moq;

namespace CareWell.BusinessService.Test.General
{
    public class ResumenDiarioBusinessTest : BusinessTestClassBase<ResumenDiarioBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IBaseFactory> baseFactory;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
        private Mock<IArmarResumenDiarioBusinessService> armarResumenDiarioBusinessService;
        private Mock<ISerializadorResumenDiario> serializadorResumenDiarioBusinessService;
        private Mock<IResumenDiarioRepository> resumenDiarioRepository;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.baseFactory = new Mock<IBaseFactory>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            this.armarResumenDiarioBusinessService = new Mock<IArmarResumenDiarioBusinessService>();
            this.serializadorResumenDiarioBusinessService = new Mock<ISerializadorResumenDiario>();
            this.resumenDiarioRepository = new Mock<IResumenDiarioRepository>();

            this.Target = new ResumenDiarioBusinessService(
                this.unitOfWork.Object,
                this.userContext.Object,
                this.baseFactory.Object,
                this.entityLoaderDomainService.Object,
                this.validadorPermisoAccion.Object,
                this.armarResumenDiarioBusinessService.Object,
                this.serializadorResumenDiarioBusinessService.Object,
                this.resumenDiarioRepository.Object
            );
        }

        public class ElMetodo_Generar : ResumenDiarioBusinessTest
        {
            private GenerarResumenDiarioQuery query;
            private Mock<Usuario> usuario;
            private Mock<Persona> personaCuidada;
            private Mock<ResumenDiario> resumenDiario;
            private ResumenDiarioDataView resumenDiarioDataView;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<GenerarResumenDiarioQuery>(q => q.PersonaCuidadaID == 99);

                this.usuario = new Mock<Usuario>();
                this.usuario.Setup(s => s.ID).Returns(1);
                this.usuario.Setup(s => s.Persona).Returns(Mock.Of<Persona>());

                this.personaCuidada = new Mock<Persona>();
                this.personaCuidada.Setup(s => s.ID).Returns(this.query.PersonaCuidadaID);
                this.personaCuidada.Setup(s => s.Nombre).Returns("Persona X");

                this.resumenDiario = new Mock<ResumenDiario>();

                this.resumenDiarioDataView = Mock.Of<ResumenDiarioDataView>();

                this.userContext.Setup(s => s.UsuarioID).Returns(this.usuario.Object.ID);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(this.usuario.Object);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Persona>(It.IsAny<int>())).Returns(this.personaCuidada.Object);

                this.resumenDiarioRepository.Setup(s => s.GetByPersona(It.IsAny<int>())).Returns(this.resumenDiario.Object);

                this.armarResumenDiarioBusinessService.Setup(s => s.Armar(It.IsAny<int>(), It.IsAny<string>(), It.IsAny<CancellationToken>())).ReturnsAsync(this.resumenDiarioDataView);

                this.baseFactory.Setup(s => s.Crear<ResumenDiario>()).Returns(this.resumenDiario.Object);

                this.serializadorResumenDiarioBusinessService.Setup(s => s.Deserializar(It.IsAny<string>())).Returns(this.resumenDiarioDataView);
            }

            private ResumenDiarioDataView Action()
            {
                return this.Target.Generar(this.query, It.IsAny<CancellationToken>()).Result;
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
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Usuario>(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Persona_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Persona>(this.query.PersonaCuidadaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarVisualizacion_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarVisualizacion(this.personaCuidada.Object, this.usuario.Object.Persona), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByPersona_del_ResumenDiarioRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.resumenDiarioRepository.Verify(v => v.GetByPersona(this.personaCuidada.Object.ID), Times.Once);
            }

            [Fact]
            public void Si_el_ResumenDiario_persistido_no_es_nulo_y_llama_una_vez_al_metodo_EsReutilizable_del_ResumenDiario()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                resumenDiario.Verify(v => v.EsReutilizable(this.query.Actualizar), Times.Once);
            }

            [Fact]
            public void Si_el_ResumenDiario_persistido_no_es_nulo_y_es_reutilizable_llama_una_vez_al_metodo_Deserializar_del_SerializadorResumenDiarioBusinessService()
            {
                // Arrange
                this.resumenDiario.Setup(s => s.EsReutilizable(It.IsAny<bool>())).Returns(true);
                this.resumenDiario.Setup(s => s.Contenido).Returns("Content");

                // Action
                this.Action();

                // Assert
                this.serializadorResumenDiarioBusinessService.Verify(v => v.Deserializar(resumenDiario.Object.Contenido), Times.Once);
            }

            [Fact]
            public void Si_el_ResumenDiario_persistido_no_es_nulo_y_es_reutilizable_no_llama_nunca_al_metodo_Armar_del_ArmarResumenDiarioBusinessService()
            {
                // Arrange
                this.resumenDiario.Setup(s => s.EsReutilizable(It.IsAny<bool>())).Returns(true);

                // Action
                this.Action();

                // Assert
                this.armarResumenDiarioBusinessService.Verify(v => v.Armar(It.IsAny<int>(), It.IsAny<string>(), It.IsAny<CancellationToken>()), Times.Never);
            }

            [Fact]
            public void Si_el_ResumenDiario_persistido_es_nulo_llama_una_vez_al_metodo_Armar_del_ArmarResumenDiarioBusinessService()
            {
                // Arrange
                this.resumenDiarioRepository.Setup(s => s.GetByPersona(this.personaCuidada.Object.ID)).Returns((ResumenDiario?)null);

                // Action
                this.Action();

                // Assert
                this.armarResumenDiarioBusinessService.Verify(v => v.Armar(this.personaCuidada.Object.ID, this.personaCuidada.Object.Nombre, It.IsAny<CancellationToken>()), Times.Once);
            }

            [Fact]
            public void Si_el_ResumenDiario_persistido_no_es_reutilizable_llama_una_vez_al_metodo_Armar_del_ArmarResumenDiarioBusinessService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.armarResumenDiarioBusinessService.Verify(v => v.Armar(this.personaCuidada.Object.ID, this.personaCuidada.Object.Nombre, It.IsAny<CancellationToken>()), Times.Once);
            }

            [Fact]
            public void Si_el_resumen_generado_tiene_datos_y_no_existia_un_resumen_persistido_llama_una_vez_al_metodo_Crear_ResumenDiario_del_BaseFactory()
            {
                // Arrange
                Mock.Get(this.resumenDiarioDataView).Setup(s => s.TieneDatos).Returns(true);
                this.resumenDiarioRepository.Setup(s => s.GetByPersona(this.personaCuidada.Object.ID)).Returns((ResumenDiario?)null);

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(s => s.Crear<ResumenDiario>(), Times.Once);
            }

            [Fact]
            public void Si_el_resumen_generado_tiene_datos_y_existia_un_resumen_persistido_no_llama_nunca_al_metodo_Crear_ResumenDiario_del_BaseFactory()
            {
                // Arrange
                Mock.Get(this.resumenDiarioDataView).Setup(s => s.TieneDatos).Returns(true);

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(s => s.Crear<ResumenDiario>(), Times.Never);
            }

            [Fact]
            public void Si_el_resumen_generado_tiene_datos_llama_una_vez_al_metodo_Serializar_del_SerializadorResumenDiarioBusinessService()
            {
                // Arrange
                Mock.Get(this.resumenDiarioDataView).Setup(s => s.TieneDatos).Returns(true);

                // Action
                this.Action();

                // Assert
                this.serializadorResumenDiarioBusinessService.Verify(s => s.Serializar(this.resumenDiarioDataView), Times.Once);
            }

            [Fact]
            public void Si_el_resumen_generado_tiene_datos_llama_una_vez_al_metodo_Generar_del_ResumenDiario()
            {
                // Arrange
                var contenido = "Content";
                this.serializadorResumenDiarioBusinessService.Setup(s => s.Serializar(It.IsAny<ResumenDiarioDataView>())).Returns(contenido);
                Mock.Get(this.resumenDiarioDataView).Setup(s => s.TieneDatos).Returns(true);

                // Action
                this.Action();

                // Assert
                this.resumenDiario.Verify(s => s.Generar(It.Is<GenerarResumenDiario>(g =>
                    g.Persona == this.personaCuidada.Object &&
                    g.Contenido == contenido &&
                    g.FechaHoraGeneracion == this.resumenDiarioDataView.GeneradoEn
                )), Times.Once);
            }

            [Fact]
            public void Si_el_resumen_generado_tiene_datos_y_el_resumen_diario_es_nuevo_llama_una_vez_al_metodo_Add_del_ResumenDiarioRepository()
            {
                // Arrange
                this.resumenDiario.Setup(s => s.IsTransient()).Returns(true);
                Mock.Get(this.resumenDiarioDataView).Setup(s => s.TieneDatos).Returns(true);

                // Action
                this.Action();

                // Assert
                this.resumenDiarioRepository.Verify(v => v.Add(this.resumenDiario.Object), Times.Once);
            }

            [Fact]
            public void Si_el_resumen_generado_tiene_datos_y_el_resumen_diario_no_es_nuevo_no_llama_nunca_al_metodo_Add_del_ResumenDiarioRepository()
            {
                // Arrange
                Mock.Get(this.resumenDiarioDataView).Setup(s => s.TieneDatos).Returns(true);

                // Action
                this.Action();

                // Assert
                this.resumenDiarioRepository.Verify(v => v.Add(It.IsAny<ResumenDiario>()), Times.Never);
            }

            [Fact]
            public void Si_el_resumen_generado_tiene_datos_y_llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork()
            {
                // Arrange
                Mock.Get(this.resumenDiarioDataView).Setup(s => s.TieneDatos).Returns(true);

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(v => v.SaveChanges(), Times.Once);
            }

            [Fact]
            public void Si_el_SaveChanges_arroja_una_DbUpdateException_no_se_arroja()
            {
                // Arrange
                Mock.Get(this.resumenDiarioDataView).Setup(s => s.TieneDatos).Returns(true);
                this.unitOfWork.Setup(s => s.SaveChanges()).Throws(new DbUpdateException());

                // Action
                var excepcion = Record.Exception(() => this.Action());

                // Assert
                Assert.Null(excepcion);
            }
        }
    }
}
