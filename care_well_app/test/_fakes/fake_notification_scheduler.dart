import 'package:care_well_app/domain/notifications/notification_scheduler.dart';

/// Implementación fake de [NotificationScheduler] para tests.
///
/// Registra los IDs de notificaciones programadas, canceladas y mostradas
/// sin invocar ninguna API del sistema operativo.
class FakeNotificationScheduler implements NotificationScheduler {
  /// IDs de notificaciones que fueron programadas.
  final List<int> scheduled = [];

  /// IDs de notificaciones que fueron canceladas.
  final List<int> cancelled = [];

  /// IDs de notificaciones inmediatas mostradas (via [showImmediateNotification]).
  final List<int> shown = [];

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleEventReminder({
    required int notificationId,
    required DateTime fechaHora,
    required String titulo,
    required String cuerpo,
    String? payload,
  }) async {
    scheduled.add(notificationId);
  }

  @override
  Future<void> cancelEventReminder(int notificationId) async {
    cancelled.add(notificationId);
  }

  @override
  Future<void> showImmediateNotification({
    required int notificationId,
    required String titulo,
    required String cuerpo,
    String? payload,
  }) async {
    shown.add(notificationId);
  }
}
