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
  Future<void> showImmediateNotification({
    required int notificationId,
    required String titulo,
    required String cuerpo,
    String? payload,
  });
}
