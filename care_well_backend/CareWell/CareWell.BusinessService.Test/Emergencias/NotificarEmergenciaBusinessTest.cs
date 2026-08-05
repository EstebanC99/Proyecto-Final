using CareWell.BusinessService.Emergencias;
using CareWell.Domain.Auth;
using CareWell.Domain.Emergencias;
using CareWell.Domain.General;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Notificaciones;
using CareWell.Notifications.Push;
using CareWell.Repository.Auth;
using CareWell.Repository.Emergencias;
using Moq;

namespace CareWell.BusinessService.Test.Emergencias
{
    public class NotificarEmergenciaBusinessTest : BusinessTestClassBase<NotificarEmergenciaBusinessService>
    {
        private Mock<IEmergenciaRepository> emergenciaRepository;
        private Mock<IDispositivoUsuarioRepository> dispositivoUsuarioRepository;
        private Mock<IPushSender> pushSender;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.emergenciaRepository = new Mock<IEmergenciaRepository>();
            this.dispositivoUsuarioRepository = new Mock<IDispositivoUsuarioRepository>();
            this.pushSender = new Mock<IPushSender>();

            this.Target = new NotificarEmergenciaBusinessService
            (
                this.emergenciaRepository.Object,
                this.dispositivoUsuarioRepository.Object,
                this.pushSender.Object
            );
        }

        public class ElMetodo_Notificar : NotificarEmergenciaBusinessTest
        {
            private Mock<Emergencia> emergencia;
            private Mock<Usuario> usuarioColaboradorActivo;
            private Mock<DispositivoUsuario> dispositivoUsuario;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.emergencia = new Mock<Emergencia>();
                this.emergencia.Setup(s => s.ID).Returns(1);
                this.emergencia.Setup(s => s.Persona).Returns(Mock.Of<Persona>(p => p.ID == 99 && p.NombreCompleto() == "Persona X"));
                this.emergencia.Setup(s => s.Activador).Returns(Mock.Of<Persona>(p => p.NombreCompleto() == "Activador X"));

                this.usuarioColaboradorActivo = new Mock<Usuario>();

                this.dispositivoUsuario = new Mock<DispositivoUsuario>();
                this.dispositivoUsuario.Setup(s => s.Token).Returns("Token X");

                this.emergenciaRepository.Setup(s => s.GetUsuariosColaboradoresActivos(this.emergencia.Object)).Returns(new List<Usuario> { this.usuarioColaboradorActivo.Object });

                this.dispositivoUsuarioRepository.Setup(s => s.GetVigentesPorUsuario(this.usuarioColaboradorActivo.Object, It.IsAny<DateTime>())).Returns(new List<DispositivoUsuario> { this.dispositivoUsuario.Object });

                this.pushSender.Setup(s => s.Enviar(It.IsAny<List<string>>(), It.IsAny<MensajePush>(), It.IsAny<CancellationToken>()))
                    .ReturnsAsync(new ResultadoEnvioPush(Enviados: 1, Fallidos: 0, TokensInvalidos: new List<string>()));
            }

            private void Action()
            {
                this.Target.Notificar(this.emergencia.Object, It.IsAny<CancellationToken>()).GetAwaiter().GetResult();
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetUsuariosColaboradoresActivos_del_EmergenciaRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.emergenciaRepository.Verify(v => v.GetUsuariosColaboradoresActivos(this.emergencia.Object), Times.Once);
            }

            [Fact]
            public void No_llama_nunca_al_metodo_Enviar_del_PushSender_si_no_hay_destinatarios()
            {
                // Arrange
                this.emergenciaRepository.Setup(s => s.GetUsuariosColaboradoresActivos(It.IsAny<Emergencia>())).Returns(new List<Usuario>());

                // Action
                this.Action();

                // Assert
                this.pushSender.Verify(v => v.Enviar(It.IsAny<List<string>>(), It.IsAny<MensajePush>(), It.IsAny<CancellationToken>()), Times.Never);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetVigentesPorUsuario_del_DispositivoUsuarioRepository_para_cada_destinatario()
            {
                // Arrange
                var fechaHoraInicioEjecucion = DateTime.Now.AddDays(-ParametrosSesion.DiasInactividadDispositivo);

                // Action
                this.Action();

                // Assert
                var fechaHoraFinEjecucion = DateTime.Now.AddDays(-ParametrosSesion.DiasInactividadDispositivo);
                this.dispositivoUsuarioRepository.Verify(v => v.GetVigentesPorUsuario(this.usuarioColaboradorActivo.Object, It.Is<DateTime>(d => d >= fechaHoraInicioEjecucion && d <= fechaHoraFinEjecucion)), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Enviar_del_PushSender()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.pushSender.Verify(v => v.Enviar(
                    It.Is<List<string>>(l =>
                        l.Contains(this.dispositivoUsuario.Object.Token)
                    ),
                    It.Is<MensajePush>(m =>
                        m.Titulo == Push.TituloEmergencia &&
                        m.Cuerpo == Push.CuerpoEmergenciaFormat(this.emergencia.Object.Activador.NombreCompleto(), this.emergencia.Object.Persona.NombreCompleto()) &&
                        m.CanalID == CanalesNotificacionPush.Emergencias &&
                        m.Datos.Any(d => d.Key == Push.ClaveTipo && d.Value == Push.TipoEmergencia) &&
                        m.Datos.Any(d => d.Key == Push.ClaveEmergenciaID && d.Value == this.emergencia.Object.ID.ToString()) &&
                        m.Datos.Any(d => d.Key == Push.ClavePersonaID && d.Value == this.emergencia.Object.Persona.ID.ToString())
                    ),
                    It.IsAny<CancellationToken>()
                ), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Desactivar_del_Dispositivo_cuyo_token_fue_invalido()
            {
                // Arrange
                this.pushSender.Setup(s => s.Enviar(It.IsAny<List<string>>(), It.IsAny<MensajePush>(), It.IsAny<CancellationToken>()))
                    .ReturnsAsync(new ResultadoEnvioPush(Enviados: 1, Fallidos: 1, TokensInvalidos: new List<string> { this.dispositivoUsuario.Object.Token }));

                // Action
                this.Action();

                // Assert
                this.dispositivoUsuario.Verify(v => v.Desactivar(), Times.Once);
            }
        }
    }
}
