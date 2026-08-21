import 'dart:async';

import 'package:care_well_app/domain/notifications/notification_channel.dart';
import 'package:care_well_app/domain/notifications/notification_payload.dart';
import 'package:care_well_app/domain/notifications/notification_scheduler.dart';

/// Implementación fake de [NotificationScheduler] para tests.
///
/// Registra los IDs de notificaciones programadas, canceladas y mostradas
/// sin invocar ninguna API del sistema operativo.
class FakeNotificationScheduler implements NotificationScheduler {
  FakeNotificationScheduler({
    this.launchPayload,
    this.puedeAlarmasExactas = true,
  });

  /// Respuesta simulada de [puedeProgramarAlarmasExactas].
  bool puedeAlarmasExactas;

  /// Cantidad de veces que se consultó el permiso de alarmas exactas.
  ///
  /// Permite verificar que una corrida de sincronización no lo consulte una
  /// vez por notificación.
  int puedeAlarmasExactasCount = 0;

  /// Cantidad de veces que se pidió abrir los Ajustes de alarmas exactas.
  int solicitarAlarmasExactasCount = 0;

  /// Payload de la notificación local que "abrió la app", si se simula.
  NotificationPayload? launchPayload;

  /// IDs de notificaciones que fueron programadas.
  final List<int> scheduled = [];

  /// IDs de notificaciones que fueron canceladas.
  final List<int> cancelled = [];

  /// IDs de notificaciones inmediatas mostradas (via [showImmediateNotification]).
  final List<int> shown = [];

  /// Canales usados en cada invocación de [showImmediateNotification],
  /// en el mismo orden que [shown].
  final List<NotificationChannel> shownChannels = [];

  /// Títulos de las notificaciones inmediatas mostradas, en el mismo orden.
  final List<String> shownTitles = [];

  /// Payloads de las notificaciones inmediatas mostradas, en el mismo orden.
  final List<String?> shownPayloads = [];

  /// Cantidad de veces que se invocó [cancelAll].
  int cancelAllCount = 0;

  final _tapController = StreamController<NotificationPayload>.broadcast();

  /// Simula que el usuario tocó una notificación local con el payload crudo
  /// [raw]. Descarta los que no se pueden decodificar, igual que la impl real.
  void emitirTap(String? raw) {
    final payload = NotificationPayload.decode(raw);
    if (payload != null) _tapController.add(payload);
  }

  Future<void> dispose() => _tapController.close();

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> puedeProgramarAlarmasExactas() async {
    puedeAlarmasExactasCount++;
    return puedeAlarmasExactas;
  }

  @override
  Future<void> solicitarPermisoAlarmasExactas() async {
    solicitarAlarmasExactasCount++;
  }

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
  Future<void> cancelAll() async {
    cancelAllCount++;
  }

  @override
  Future<void> showImmediateNotification({
    required int notificationId,
    required String titulo,
    required String cuerpo,
    String? payload,
    NotificationChannel canal = NotificationChannel.agenda,
  }) async {
    shown.add(notificationId);
    shownChannels.add(canal);
    shownTitles.add(titulo);
    shownPayloads.add(payload);
  }

  @override
  Stream<NotificationPayload> get onNotificationTap => _tapController.stream;

  @override
  Future<NotificationPayload?> getLaunchPayload() async => launchPayload;
}
