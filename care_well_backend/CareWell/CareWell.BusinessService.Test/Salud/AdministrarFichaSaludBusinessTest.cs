using CareWell.BusinessService.Salud;
using CareWell.Commands.Salud;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Queries.Salud;
using CareWell.Repository.Salud;
using CareWell.Security;
using Moq;

namespace CareWell.BusinessService.Test.Salud
{
    public class AdministrarFichaSaludBusinessTest : BusinessTestClassBase<AdministrarFichaSaludBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IBaseFactory> baseFactory;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IFichaSaludRepository> fichaSaludRepository;
        private Mock<IValidadorPermisoAccion> validadorPermisoAccion;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.baseFactory = new Mock<IBaseFactory>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.fichaSaludRepository = new Mock<IFichaSaludRepository>();
            this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();

            this.Target = new AdministrarFichaSaludBusinessService(
                this.unitOfWork.Object,
                this.userContext.Object,
                this.baseFactory.Object,
                this.entityLoaderDomainService.Object,
                this.fichaSaludRepository.Object,
                this.validadorPermisoAccion.Object
            );
        }

        public class ElMetodo_Obtener : AdministrarFichaSaludBusinessTest
        {
            private FichaSaludQuery query;
            private Persona persona;
            private Usuario usuarioLogueado;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<FichaSaludQuery>(q => q.PersonaID == 1);
                this.persona = Mock.Of<Persona>();
                this.usuarioLogueado = Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>());

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(this.usuarioLogueado);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Persona>(this.query.PersonaID)).Returns(this.persona);
            }

            private void Action()
            {
                this.Target.Obtener(this.query);
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
                this.entityLoaderDomainService.Verify(v => v.GetByID<Persona>(this.query.PersonaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeVerFichaSalud_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeVerFichaSalud(this.persona, this.usuarioLogueado.Persona), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Obtener_del_FichaSaludRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.fichaSaludRepository.Verify(v => v.Obtener(this.query), Times.Once);
            }
        }

        public class ElMetodo_Crear : AdministrarFichaSaludBusinessTest
        {
            private CrearFichaSaludCommand command;
            private Mock<FichaSalud> fichaSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<CrearFichaSaludCommand>(c =>
                    c.PersonaID == 1 &&
                    c.Antecedentes == new List<AgregarAntecedenteCommand>() &&
                    c.Alergias == new List<AgregarAlergiaCommand>() &&
                    c.Enfermedades == new List<AgregarEnfermedadCommand>()
                );

                this.fichaSalud = new Mock<FichaSalud>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.baseFactory.Setup(s => s.Crear<FichaSalud>()).Returns(this.fichaSalud.Object);
            }

            private void Action()
            {
                this.Target.Crear(this.command);
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
                this.entityLoaderDomainService.Verify(v => v.GetByID<Persona>(this.command.PersonaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_FichaSalud_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<FichaSalud>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_del_FichaSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.fichaSalud.Verify(v => v.Crear(It.IsAny<CrearFichaSalud>(),
                                                    this.validadorPermisoAccion.Object,
                                                    this.baseFactory.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_FichaSaludRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.fichaSaludRepository.Verify(v => v.Add(this.fichaSalud.Object), Times.Once);
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

        public class ElMetodo_Modificar : AdministrarFichaSaludBusinessTest
        {
            private ModificarFichaSaludCommand command;
            private Mock<FichaSalud> fichaSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<ModificarFichaSaludCommand>(c =>
                    c.ID == 1 &&
                    c.Antecedentes == new List<AgregarAntecedenteCommand>() &&
                    c.Alergias == new List<AgregarAlergiaCommand>() &&
                    c.Enfermedades == new List<AgregarEnfermedadCommand>()
                );

                this.fichaSalud = new Mock<FichaSalud>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.fichaSaludRepository.Setup(s => s.GetByID(this.command.ID)).Returns(this.fichaSalud.Object);
            }

            private void Action()
            {
                this.Target.Modificar(this.command);
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
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(v => v.GetByID<Usuario>(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_del_FichaSaludRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.fichaSaludRepository.Verify(v => v.GetByID(this.command.ID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Modificar_del_FichaSalud()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.fichaSalud.Verify(v => v.Modificar(It.IsAny<ModificarFichaSalud>(),
                                                        this.validadorPermisoAccion.Object,
                                                        this.baseFactory.Object), Times.Once);
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
