using CareWell.BusinessService.Abstractions.Salud;
using CareWell.BusinessService.Agenda;
using CareWell.Commands.Agenda;
using CareWell.DataViews.Agenda;
using CareWell.Domain.Agenda;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.DomainServices.Agenda;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Agenda;
using CareWell.Queries.Agenda;
using CareWell.Repository.Agenda;
using CareWell.Security;
using Moq;

namespace CareWell.BusinessService.Test.Agenda
{
    public class AdministrarEventoAgendaBusinessTest : BusinessTestClassBase<AdministrarEventoAgendaBusinessService>
    {
        private Mock<IUserContext> userContext;
        private Mock<IBaseFactory> baseFactory;
        private Mock<IEntityLoaderDomainService> entityLoaderDomainService;
        private Mock<IEventoAgendaRepository> eventoAgendaRepository;
        private Mock<IExpansorRecurrenciaDomainService> expansorRecurrenciaDomainService;
        private Mock<ISerializadorFechasExceptuadasDomainService> serializadorFechasExceptuadasDomainService;
        private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
        private Mock<IGenerarEventoSaludBusinessService> generarEventoSaludBusinessService;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.userContext = new Mock<IUserContext>();
            this.baseFactory = new Mock<IBaseFactory>();
            this.entityLoaderDomainService = new Mock<IEntityLoaderDomainService>();
            this.eventoAgendaRepository = new Mock<IEventoAgendaRepository>();
            this.expansorRecurrenciaDomainService = new Mock<IExpansorRecurrenciaDomainService>();
            this.serializadorFechasExceptuadasDomainService = new Mock<ISerializadorFechasExceptuadasDomainService>();
            this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();
            this.generarEventoSaludBusinessService = new Mock<IGenerarEventoSaludBusinessService>();

            this.Target = new AdministrarEventoAgendaBusinessService(
                this.unitOfWork.Object,
                this.userContext.Object,
                this.baseFactory.Object,
                this.entityLoaderDomainService.Object,
                this.eventoAgendaRepository.Object,
                this.expansorRecurrenciaDomainService.Object,
                this.serializadorFechasExceptuadasDomainService.Object,
                this.validadorPermisoAccion.Object,
                this.generarEventoSaludBusinessService.Object
            );
        }

        public class ElMetodo_ObtenerOcurrencias : AdministrarEventoAgendaBusinessTest
        {
            private ObtenerEventosAgendaQuery query;
            private Mock<Persona> persona;
            private Mock<Usuario> usuario;
            private Mock<EventoAgenda> eventoAgenda;
            private DateTime fechaHoraRecurrencia;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.query = Mock.Of<ObtenerEventosAgendaQuery>(q =>
                    q.PersonaID == 1 &&
                    q.FechaDesde == DateTime.Now &&
                    q.FechaHasta == DateTime.Now.AddDays(5)
                );

                this.persona = new Mock<Persona>();
                this.persona.Setup(s => s.ID).Returns(1);

                this.usuario = new Mock<Usuario>();
                this.usuario.Setup(s => s.ID).Returns(99);
                this.usuario.Setup(s => s.Persona).Returns(Mock.Of<Persona>(p => p.ID == 2));

                this.fechaHoraRecurrencia = DateTime.Now;

                this.eventoAgenda = new Mock<EventoAgenda>();
                this.eventoAgenda.Setup(s => s.ObtenerOcurrenciasEnRango(this.expansorRecurrenciaDomainService.Object, It.IsAny<DateTime>(), It.IsAny<DateTime>())).Returns(new List<DateTime> { this.fechaHoraRecurrencia });
                this.eventoAgenda.Setup(s => s.Persona).Returns(this.persona.Object);
                this.eventoAgenda.Setup(s => s.Tipo).Returns(Mock.Of<TipoEvento>(t => t.ID == 1 && t.Descripcion == "Evento Prueba"));

                this.userContext.Setup(s => s.UsuarioID).Returns(this.usuario.Object.ID);

                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(this.usuario.Object.ID)).Returns(this.usuario.Object);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Persona>(this.persona.Object.ID)).Returns(this.persona.Object);

                this.eventoAgendaRepository.Setup(s => s.GetAllByPersonaEnRango(It.IsAny<int>(), It.IsAny<DateTime>(), It.IsAny<DateTime>())).Returns(new List<EventoAgenda> { this.eventoAgenda.Object });
            }

            private List<OcurrenciaEventoAgendaDataView> Action()
            {
                return this.Target.ObtenerOcurrencias(this.query);
            }

            [Fact]
            public void Lee_el_UsuarioID_del_UserContext()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.userContext.Verify(s => s.UsuarioID, Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(s => s.GetByID<Usuario>(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Persona_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(s => s.GetByID<Persona>(this.query.PersonaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarVisualizacion_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(s => s.ValidarVisualizacion(this.persona.Object, this.usuario.Object.Persona), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GenerarPendientes_del_GenerarEventoSaludBusinessService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.generarEventoSaludBusinessService.Verify(s => s.GenerarPendientes(this.persona.Object.ID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetAllByPersonaEnRango_del_EventoAgendaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgendaRepository.Verify(s => s.GetAllByPersonaEnRango(this.persona.Object.ID, query.FechaDesde, query.FechaHasta), Times.Once);
            }

            [Fact]
            public void Llama_al_metodo_ObtenerOcurrenciasEnRango_de_los_eventos_recuperados()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgenda.Verify(s => s.ObtenerOcurrenciasEnRango(this.expansorRecurrenciaDomainService.Object, query.FechaDesde, query.FechaHasta), Times.Once);
            }

            [Fact]
            public void Mapea_el_EventoAgendaID_de_la_respuesta()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.eventoAgenda.Object.ID, resultado.First().EventoAgendaID);
            }

            [Fact]
            public void Mapea_el_PersonaID_de_la_respuesta()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.eventoAgenda.Object.Persona.ID, resultado.First().PersonaID);
            }

            [Fact]
            public void Mapea_el_Titulo_de_la_respuesta()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.eventoAgenda.Object.Titulo, resultado.First().Titulo);
            }

            [Fact]
            public void Mapea_la_Descripcion_de_la_respuesta()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.eventoAgenda.Object.Descripcion, resultado.First().Descripcion);
            }

            [Fact]
            public void Mapea_el_TipoEventoID_de_la_respuesta()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.eventoAgenda.Object.Tipo.ID, resultado.First().Tipo.ID);
            }

            [Fact]
            public void Mapea_el_TipoEventoDescripcion_de_la_respuesta()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.eventoAgenda.Object.Tipo.Descripcion, resultado.First().Tipo.Descripcion);
            }

            [Fact]
            public void Mapea_la_FechaHoraInicio_de_la_respuesta()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.fechaHoraRecurrencia, resultado.First().FechaHoraInicio);
            }

            [Fact]
            public void Mapea_la_FechaHoraFin_de_la_respuesta()
            {
                // Arrange
                this.eventoAgenda.Setup(s => s.Duracion).Returns(TimeSpan.FromHours(DateTime.Now.Hour));

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.fechaHoraRecurrencia.Add(this.eventoAgenda.Object.Duracion), resultado.First().FechaHoraFin);
            }

            [Fact]
            public void Mapea_el_EsRecurrende_de_la_respuesta()
            {
                // Arrange
                this.eventoAgenda.Setup(s => s.ReglaRecurrencia).Returns("Regla");

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.eventoAgenda.Object.ReglaRecurrencia != null, resultado.First().EsRecurrente);
            }

            [Fact]
            public void Mapea_el_GenerarEventoSalud_de_la_respuesta()
            {
                // Arrange
                this.eventoAgenda.Setup(s => s.GenerarEventoSalud).Returns(true);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.eventoAgenda.Object.GenerarEventoSalud, resultado.First().GenerarEventoSalud);
            }

            [Fact]
            public void Mapea_el_MinutosAnticipacionRecordatorio_de_la_respuesta()
            {
                // Arrange
                this.eventoAgenda.Setup(s => s.MinutosAnticipacionRecordatorio).Returns(1);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.eventoAgenda.Object.MinutosAnticipacionRecordatorio, resultado.First().MinutosAnticipacionRecordatorio);
            }

            [Fact]
            public void Retora_una_lista_del_tipo_OcurrenciaEventoAgendaDataView()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<List<OcurrenciaEventoAgendaDataView>>(resultado);
            }
        }

        public class ElMetodo_Crear : AdministrarEventoAgendaBusinessTest
        {
            private CrearEventoAgendaCommand command;
            private Mock<EventoAgenda> eventoAgenda;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<CrearEventoAgendaCommand>(c =>
                    c.PersonaID == 1 &&
                    c.TipoEventoID == 2 &&
                    c.DuracionMinutos == 30
                );

                this.eventoAgenda = new Mock<EventoAgenda>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.baseFactory.Setup(s => s.Crear<EventoAgenda>()).Returns(this.eventoAgenda.Object);
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
                this.userContext.Verify(s => s.UsuarioID, Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(s => s.GetByID<Usuario>(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Persona_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(s => s.GetByID<Persona>(this.command.PersonaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_TipoEvento_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(s => s.GetByID<TipoEvento>(this.command.TipoEventoID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_EventoAgenda_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(s => s.Crear<EventoAgenda>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_del_EventoAgenda()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgenda.Verify(s => s.Crear(It.IsAny<CrearEventoAgenda>(),
                                                      this.expansorRecurrenciaDomainService.Object,
                                                      this.validadorPermisoAccion.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_EventoAgendaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgendaRepository.Verify(s => s.Add(this.eventoAgenda.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(s => s.SaveChanges(), Times.Once);
            }
        }

        public class ElMetodo_Modificar : AdministrarEventoAgendaBusinessTest
        {
            private ModificarEventoAgendaCommand command;
            private Mock<EventoAgenda> eventoAgenda;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<ModificarEventoAgendaCommand>(c =>
                    c.EventoAgendaID == 1 &&
                    c.TipoEventoID == 2 &&
                    c.DuracionMinutos == 30
                );

                this.eventoAgenda = new Mock<EventoAgenda>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.eventoAgendaRepository.Setup(s => s.GetByID(this.command.EventoAgendaID)).Returns(this.eventoAgenda.Object);
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
                this.userContext.Verify(s => s.UsuarioID, Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(s => s.GetByID<Usuario>(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_del_EventoAgendaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgendaRepository.Verify(s => s.GetByID(this.command.EventoAgendaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_TipoEvento_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(s => s.GetByID<TipoEvento>(this.command.TipoEventoID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Modificar_del_EventoAgenda()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgenda.Verify(s => s.Modificar(It.IsAny<ModificarEventoAgenda>(),
                                                          this.expansorRecurrenciaDomainService.Object,
                                                          this.validadorPermisoAccion.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(s => s.SaveChanges(), Times.Once);
            }
        }

        public class ElMetodo_Eliminar : AdministrarEventoAgendaBusinessTest
        {
            private int eventoAgendaID;
            private Mock<EventoAgenda> eventoAgenda;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.eventoAgendaID = 1;

                this.eventoAgenda = new Mock<EventoAgenda>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.eventoAgendaRepository.Setup(s => s.GetByID(this.eventoAgendaID)).Returns(this.eventoAgenda.Object);
            }

            private void Action()
            {
                this.Target.Eliminar(this.eventoAgendaID);
            }

            [Fact]
            public void Lee_el_UsuarioID_del_UserContext()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.userContext.Verify(s => s.UsuarioID, Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(s => s.GetByID<Usuario>(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_del_EventoAgendaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgendaRepository.Verify(s => s.GetByID(this.eventoAgendaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Eliminar_del_EventoAgenda()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgenda.Verify(s => s.Eliminar(this.validadorPermisoAccion.Object,
                                                         It.IsAny<Persona>()), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Remove_del_EventoAgendaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgendaRepository.Verify(s => s.Remove(this.eventoAgenda.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(s => s.SaveChanges(), Times.Once);
            }
        }

        public class ElMetodo_CancelarOcurrencia : AdministrarEventoAgendaBusinessTest
        {
            private CancelarOcurrenciaEventoAgendaCommand command;
            private Mock<EventoAgenda> eventoAgenda;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<CancelarOcurrenciaEventoAgendaCommand>(c =>
                    c.EventoAgendaID == 1 &&
                    c.FechaOcurrencia == DateTime.Now
                );

                this.eventoAgenda = new Mock<EventoAgenda>();

                this.userContext.Setup(s => s.UsuarioID).Returns(99);
                this.entityLoaderDomainService.Setup(s => s.GetByID<Usuario>(It.IsAny<int>())).Returns(Mock.Of<Usuario>(u => u.Persona == Mock.Of<Persona>()));

                this.eventoAgendaRepository.Setup(s => s.GetByID(this.command.EventoAgendaID)).Returns(this.eventoAgenda.Object);
            }

            private void Action()
            {
                this.Target.CancelarOcurrencia(this.command);
            }

            [Fact]
            public void Lee_el_UsuarioID_del_UserContext()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.userContext.Verify(s => s.UsuarioID, Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_Usuario_del_EntityLoaderDomainService()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.entityLoaderDomainService.Verify(s => s.GetByID<Usuario>(this.userContext.Object.UsuarioID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetByID_del_EventoAgendaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgendaRepository.Verify(s => s.GetByID(this.command.EventoAgendaID), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_CancelarOcurrencia_del_EventoAgenda()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgenda.Verify(s => s.CancelarOcurrencia(this.command.FechaOcurrencia,
                                                                   It.IsAny<Persona>(),
                                                                   this.serializadorFechasExceptuadasDomainService.Object,
                                                                   this.validadorPermisoAccion.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(s => s.SaveChanges(), Times.Once);
            }
        }
    }
}
