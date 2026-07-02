using CareWell.BusinessService.Salud;
using CareWell.Domain.Agenda;
using CareWell.Domain.DomainServices.Agenda;
using CareWell.Domain.Factories;
using CareWell.Domain.Salud;
using CareWell.Repository.Agenda;
using CareWell.Repository.Salud;
using Moq;

namespace CareWell.BusinessService.Test.Salud
{
    public class GenerarEventoSaludBusinessTest : BusinessTestClassBase<GenerarEventoSaludBusinessService>
    {
        private Mock<IBaseFactory> baseFactory;
        private Mock<IEventoAgendaRepository> eventoAgendaRepository;
        private Mock<IEventoSaludRepository> eventoSaludRepository;
        private Mock<IExpansorRecurrenciaDomainService> expansorRecurrenciaDomainService;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.baseFactory = new Mock<IBaseFactory>();
            this.eventoAgendaRepository = new Mock<IEventoAgendaRepository>();
            this.eventoSaludRepository = new Mock<IEventoSaludRepository>();
            this.expansorRecurrenciaDomainService = new Mock<IExpansorRecurrenciaDomainService>();

            this.Target = new GenerarEventoSaludBusinessService(this.unitOfWork.Object,
                                                                this.baseFactory.Object,
                                                                this.eventoAgendaRepository.Object,
                                                                this.eventoSaludRepository.Object,
                                                                this.expansorRecurrenciaDomainService.Object);
        }

        public class ElMetodo_GenerarPendientes : GenerarEventoSaludBusinessTest
        {
            private int personaID;
            private DateTime fechaOcurrencia;
            private Mock<EventoAgenda> eventoAgenda;
            private Mock<EventoSalud> eventoSalud;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.personaID = 1;
                this.fechaOcurrencia = DateTime.Now;

                this.eventoAgenda = new Mock<EventoAgenda>();
                this.eventoAgenda.Setup(s => s.ID).Returns(2);
                this.eventoAgenda.Setup(s => s.ObtenerOcurrencias(this.expansorRecurrenciaDomainService.Object, It.IsAny<DateTime>())).Returns(new List<DateTime> { this.fechaOcurrencia });

                this.eventoSalud = new Mock<EventoSalud>();

                this.eventoAgendaRepository.Setup(s => s.GetAllWithGeneracionEventoSaludPendiente(this.personaID, It.IsAny<DateTime>())).Returns(new List<EventoAgenda> { this.eventoAgenda.Object });

                this.baseFactory.Setup(s => s.Crear<EventoSalud>()).Returns(this.eventoSalud.Object);
            }

            private void Action()
            {
                this.Target.GenerarPendientes(this.personaID);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetAllWithGeneracionEventoSaludPendiente_del_EventoAgendaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgendaRepository.Verify(x => x.GetAllWithGeneracionEventoSaludPendiente(this.personaID, It.IsAny<DateTime>()), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ObtenerOcurrencias_de_cada_EventoAgenda()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgenda.Verify(x => x.ObtenerOcurrencias(this.expansorRecurrenciaDomainService.Object, It.IsAny<DateTime>()), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ExistePorOrigen_de_EventoSaludRepository_por_cada_ocurrencia()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSaludRepository.Verify(x => x.ExistePorOrigen(this.eventoAgenda.Object.ID, this.fechaOcurrencia), Times.Once);
            }

            [Fact]
            public void Si_existe_un_evento_de_salud_para_ese_evento_de_agenda_y_fecha_de_ocurrencia_no_llama_nunca_al_metodo_Crear_EventoSalud_de_la_BaseFactory()
            {
                // Arrange
                this.eventoSaludRepository.Setup(x => x.ExistePorOrigen(this.eventoAgenda.Object.ID, this.fechaOcurrencia)).Returns(true);

                // Action
                this.Action();

                // Assert
                this.eventoSaludRepository.Verify(x => x.ExistePorOrigen(this.eventoAgenda.Object.ID, this.fechaOcurrencia), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_EventoSalud_de_la_BaseFactory_por_cada_ocurrencia()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(x => x.Crear<EventoSalud>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GenerarDesdeAgenda_del_EventoSalud_por_cada_ocurrencia()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSalud.Verify(x => x.GenerarDesdeAgenda(this.eventoAgenda.Object, this.fechaOcurrencia), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_EventoSaludRepository_por_cada_ocurrencia()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoSaludRepository.Verify(x => x.Add(this.eventoSalud.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ActualizarUltimaGeneracionEventoSalud_del_EventoAgenda()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.eventoAgenda.Verify(x => x.ActualizarUltimaGeneracionEventoSalud(It.IsAny<DateTime>()), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(x => x.SaveChanges(), Times.Once);
            }
        }
    }
}
