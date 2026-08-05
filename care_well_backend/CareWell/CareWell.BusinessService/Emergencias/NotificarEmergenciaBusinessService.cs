using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices.Emergencias;
using CareWell.Domain.Emergencias;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Notificaciones;
using CareWell.Notifications.Push;
using CareWell.Repository.Auth;
using CareWell.Repository.Emergencias;

namespace CareWell.BusinessService.Emergencias
{
    public class NotificarEmergenciaBusinessService : INotificarEmergenciaDomainService
    {
        private IEmergenciaRepository EmergenciaRepository { get; set; }
        private IDispositivoUsuarioRepository DispositivoUsuarioRepository { get; set; }
        private IPushSender PushSender { get; set; }

        public NotificarEmergenciaBusinessService(IEmergenciaRepository emergenciaRepository,
                                                  IDispositivoUsuarioRepository dispositivoUsuarioRepository,
                                                  IPushSender pushSender)
        {
            this.EmergenciaRepository = emergenciaRepository;
            this.DispositivoUsuarioRepository = dispositivoUsuarioRepository;
            this.PushSender = pushSender;
        }

        public async Task Notificar(Emergencia emergencia, CancellationToken cancellationToken)
        {
            var usuariosDestinatarios = this.EmergenciaRepository.GetUsuariosColaboradoresActivos(emergencia);

            if (usuariosDestinatarios.Count == default) return;

            var dispositivos = new List<DispositivoUsuario>();
            var fechaLimiteActividad = DateTime.Now.AddDays(-ParametrosSesion.DiasInactividadDispositivo);

            foreach (var usuario in usuariosDestinatarios)
            {
                dispositivos.AddRange(this.DispositivoUsuarioRepository.GetVigentesPorUsuario(usuario, fechaLimiteActividad));
            }

            var mensaje = new MensajePush
            (
                Titulo: Push.TituloEmergencia,
                Cuerpo: Push.CuerpoEmergenciaFormat(emergencia.Activador.NombreCompleto(), emergencia.Persona.NombreCompleto()),
                CanalID: CanalesNotificacionPush.Emergencias,
                Datos: new Dictionary<string, string>
                {
                    { Push.ClaveTipo, Push.TipoEmergencia },
                    { Push.ClaveEmergenciaID, emergencia.ID.ToString() },
                    { Push.ClavePersonaID, emergencia.Persona.ID.ToString() }
                }
            );

            var tokens = dispositivos.Select(d => d.Token).ToList();

            var resultado = await this.PushSender.Enviar(tokens, mensaje, cancellationToken);

            if (resultado is null || resultado.TokensInvalidos.Count == default)
                return;

            foreach (var dispositivo in dispositivos.Where(d => resultado.TokensInvalidos.Contains(d.Token)))
            {
                dispositivo.Desactivar();
            }
        }
    }
}
