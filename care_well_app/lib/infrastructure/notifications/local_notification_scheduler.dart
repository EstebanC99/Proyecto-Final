import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/notifications/notification_scheduler.dart';

/// Implementación concreta de [NotificationScheduler] usando
/// `flutter_local_notifications` y `timezone`.
///
/// Solo esta clase y `main.dart` importan los paquetes de notificaciones.
class LocalNotificationScheduler implements NotificationScheduler {
  static const _channelId = 'agenda_reminders';
  static const _channelName = 'Recordatorios de agenda';

  final _plugin = FlutterLocalNotificationsPlugin();

  /// Retorna un id de notificación positivo a partir del id entero del evento.
  ///
  /// Se usa `& 0x7fffffff` para garantizar un valor positivo en caso de
  /// desbordamiento de signo, compatible con la API de notificaciones de Android.
  static int notificationIdFor(int eventoId) => eventoId & 0x7fffffff;

  @override
  Future<void> init() async {
    tz.initializeTimeZones();
    // TODO(timezone): detectar zona dinámica con flutter_timezone cuando se agregue.
    tz.setLocalLocation(tz.getLocation('America/Argentina/Buenos_Aires'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // TODO(deeplink): navegar al evento vía payload (details.payload = eventId).
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.high,
          ),
        );
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  @override
  Future<void> scheduleEventReminder({
    required int notificationId,
    required DateTime fechaHora,
    required String titulo,
    required String cuerpo,
    String? payload,
  }) async {
    // Si la fecha ya pasó, no programar.
    if (!fechaHora.isAfter(DateTime.now())) return;

    final tzDateTime = tz.TZDateTime.from(fechaHora, tz.local);
    await _plugin.zonedSchedule(
      notificationId,
      titulo,
      cuerpo,
      tzDateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  @override
  Future<void> cancelEventReminder(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  @override
  Future<void> showImmediateNotification({
    required int notificationId,
    required String titulo,
    required String cuerpo,
    String? payload,
  }) async {
    await _plugin.show(
      notificationId,
      titulo,
      cuerpo,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }
}
