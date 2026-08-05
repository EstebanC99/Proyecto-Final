import 'notification_channel.dart';
import 'notification_payload.dart';

/// Contrato para programar y cancelar notificaciones locales de recordatorios.
///
/// Implementado en la capa infrastructure. La capa domain no importa
/// paquetes externos: esta interfaz es Dart puro.
abstract class NotificationScheduler {
  /// Inicializa el sistema de notificaciones y crea los canales necesarios.
  Future<void> init();

  /// Solicita permiso al sistema operativo para mostrar notificaciones.
  ///
  /// Retorna `true` si el permiso fue otorgado.
  Future<bool> requestPermission();

  /// Programa un recordatorio para el evento indicado.
  ///
  /// Si [fechaHora] ya pasó, la implementación NO debe programar la notificación.
  Future<void> scheduleEventReminder({
    required int notificationId,
    required DateTime fechaHora,
    required String titulo,
    required String cuerpo,
    String? payload,
  });

  /// Cancela el recordatorio con el [notificationId] dado.
  Future<void> cancelEventReminder(int notificationId);

  /// Cancela todas las notificaciones programadas.
  ///
  /// Se usa para resincronizar la agenda: se limpia todo y se reprograma
  /// el estado vigente de ocurrencias.
  Future<void> cancelAll();

  /// Muestra una notificación local inmediata (sin programación futura).
  ///
  /// [canal] determina la importancia con la que se presenta al usuario.
  Future<void> showImmediateNotification({
    required int notificationId,
    required String titulo,
    required String cuerpo,
    String? payload,
    NotificationChannel canal = NotificationChannel.agenda,
  });

  /// Payloads de las notificaciones locales que el usuario tocó con la app
  /// abierta.
  ///
  /// Emite solo los que se pudieron decodificar; los inválidos se descartan.
  /// Quién navega a dónde es decisión de presentation: acá solo sale el dato.
  Stream<NotificationPayload> get onNotificationTap;

  /// Payload de la notificación local que abrió la app, si fue así.
  ///
  /// Va aparte de [onNotificationTap] porque el scheduler se inicializa antes
  /// de que exista un suscriptor: un stream broadcast perdería ese evento
  /// siempre. Es el mismo rol que cumple `getInitialMessage()` en el servicio
  /// de push.
  Future<NotificationPayload?> getLaunchPayload();
}
