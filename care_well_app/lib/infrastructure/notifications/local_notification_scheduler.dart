import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/notifications/notification_channel.dart';
import '../../domain/notifications/notification_id.dart';
import '../../domain/notifications/notification_payload.dart';
import '../../domain/notifications/notification_scheduler.dart';

/// Traduce la disponibilidad de alarmas exactas al modo de programación de
/// Android.
///
/// Vive fuera de la clase para poder verificarse sin el plugin ni el binding
/// de Flutter: es la única decisión con lógica de todo el camino.
///
/// - `true`  → [AndroidScheduleMode.exactAllowWhileIdle]: dispara a la hora
///   exacta incluso con el dispositivo en Doze.
/// - `false` → [AndroidScheduleMode.inexactAllowWhileIdle]: el sistema agrupa
///   la alarma y puede atrasarla de minutos a horas.
AndroidScheduleMode resolveScheduleMode(bool canScheduleExact) =>
    canScheduleExact
    ? AndroidScheduleMode.exactAllowWhileIdle
    : AndroidScheduleMode.inexactAllowWhileIdle;

/// Implementación concreta de [NotificationScheduler] usando
/// `flutter_local_notifications` y `timezone`.
///
/// Solo esta clase y `main.dart` importan los paquetes de notificaciones.
class LocalNotificationScheduler implements NotificationScheduler {
  static const _channelId = 'agenda_reminders';
  static const _channelName = 'Recordatorios de agenda';

  /// Canal de las alertas de emergencia.
  ///
  /// El id es un CONTRATO con el backend (`CanalesNotificacionPush.Emergencias`)
  /// y con el `default_notification_channel_id` del `AndroidManifest.xml`: si no
  /// coincide carácter por carácter, la notificación push llega con importancia
  /// por defecto y no suena.
  static const _channelEmergenciaId = 'emergencias';
  static const _channelEmergenciaName = 'Emergencias';

  final _plugin = FlutterLocalNotificationsPlugin();

  final _tapController = StreamController<NotificationPayload>.broadcast();

  /// Payload de la notificación que abrió la app, resuelto en [init].
  NotificationPayload? _launchPayload;

  /// Última respuesta conocida de `canScheduleExactNotifications()`.
  ///
  /// Arranca en `false` (degradación segura): programar en modo exacto sin
  /// permiso lanza una excepción de plataforma.
  bool _puedeExactas = false;

  /// Momento en que se resolvió [_puedeExactas]; `null` si la caché está sucia.
  DateTime? _puedeExactasAt;

  /// Vigencia de [_puedeExactas] durante la programación.
  ///
  /// Una resincronización programa cientos de recordatorios y consultar el
  /// permiso en cada uno serían cientos de round-trips al platform channel
  /// durante el arranque. Con esta ventana, una corrida completa lo consulta
  /// una sola vez. El permiso solo cambia si el usuario sale a Ajustes, y ese
  /// camino invalida la caché explícitamente.
  static const _vigenciaPuedeExactas = Duration(seconds: 60);

  /// Retorna un id de notificación positivo a partir del id entero del evento.
  ///
  /// Se usa `& 0x7fffffff` para garantizar un valor positivo en caso de
  /// desbordamiento de signo, compatible con la API de notificaciones de Android.
  static int notificationIdFor(int eventoId) => eventoId & 0x7fffffff;

  /// Deriva un id de notificación estable a partir del evento base y la fecha
  /// de la ocurrencia. Delega en [NotificationId.forOcurrencia] (la lógica vive
  /// en `domain`); se mantiene acá por conveniencia de la impl de infraestructura.
  static int notificationIdForOcurrencia(
    int eventoAgendaId,
    DateTime fechaOcurrencia,
  ) => NotificationId.forOcurrencia(eventoAgendaId, fechaOcurrencia);

  @override
  Future<void> init() async {
    tz.initializeTimeZones();
    // TODO(timezone): detectar zona dinámica con flutter_timezone cuando se agregue.
    tz.setLocalLocation(tz.getLocation('America/Argentina/Buenos_Aires'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) {
        final payload = NotificationPayload.decode(details.payload);
        if (payload != null) _tapController.add(payload);
      },
    );

    // La app pudo haber sido abierta por una notificación local. Ese payload no
    // puede publicarse en el stream: init() corre antes de runApp(), así que
    // todavía no hay suscriptores y el evento se perdería.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _launchPayload = NotificationPayload.decode(
        launchDetails?.notificationResponse?.payload,
      );
    }

    final androidPlugin = _androidPlugin;

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.high,
      ),
    );

    // Las emergencias usan la importancia máxima: deben interrumpir.
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelEmergenciaId,
        _channelEmergenciaName,
        importance: Importance.max,
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    final android = _androidPlugin;
    final concedido = await android?.requestNotificationsPermission() ?? false;

    // En Android 12 abre el diálogo de alarmas exactas; en 33+ es un no-op
    // porque USE_EXACT_ALARM viene concedido. El resultado NO altera el valor
    // de retorno: acá se responde por el permiso de notificaciones.
    await android?.requestExactAlarmsPermission();
    await _refrescarPuedeExactas();

    return concedido;
  }

  @override
  Future<bool> puedeProgramarAlarmasExactas() => _refrescarPuedeExactas();

  @override
  Future<void> solicitarPermisoAlarmasExactas() async {
    await _androidPlugin?.requestExactAlarmsPermission();
    // El usuario resuelve en una pantalla del sistema: al volver, la caché
    // quedó vieja y hay que invalidarla para que el banner refleje la realidad.
    _puedeExactasAt = null;
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
    final modo = resolveScheduleMode(await _puedeExactasCacheado());

    try {
      await _zonedSchedule(
        notificationId: notificationId,
        titulo: titulo,
        cuerpo: cuerpo,
        cuando: tzDateTime,
        modo: modo,
        payload: payload,
      );
    } on PlatformException {
      // El permiso pudo revocarse entre la consulta y la programación. Antes de
      // dejar al usuario sin recordatorio, se reintenta en modo inexacto: llega
      // tarde, pero llega.
      if (modo == AndroidScheduleMode.inexactAllowWhileIdle) rethrow;
      _puedeExactas = false;
      _puedeExactasAt = DateTime.now();
      await _zonedSchedule(
        notificationId: notificationId,
        titulo: titulo,
        cuerpo: cuerpo,
        cuando: tzDateTime,
        modo: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    }
  }

  @override
  Future<void> cancelEventReminder(int notificationId) async {
    await _plugin.cancel(id: notificationId);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  @override
  Future<void> showImmediateNotification({
    required int notificationId,
    required String titulo,
    required String cuerpo,
    String? payload,
    NotificationChannel canal = NotificationChannel.agenda,
  }) async {
    await _plugin.show(
      id: notificationId,
      title: titulo,
      body: cuerpo,
      notificationDetails: NotificationDetails(
        android: _androidDetailsFor(canal),
      ),
      payload: payload,
    );
  }

  @override
  Stream<NotificationPayload> get onNotificationTap => _tapController.stream;

  @override
  Future<NotificationPayload?> getLaunchPayload() async => _launchPayload;

  /// Libera el controller de taps.
  ///
  /// En producción no tiene llamador: el scheduler se crea en `main.dart` y
  /// vive todo el proceso. Existe para que los tests no filtren el stream.
  Future<void> dispose() => _tapController.close();

  /// Implementación Android del plugin; `null` en el resto de las plataformas.
  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Consulta el permiso al sistema y actualiza la caché.
  ///
  /// Fuera de Android no hay alarmas exactas que negociar: se responde `false`
  /// y los recordatorios quedan en modo inexacto.
  Future<bool> _refrescarPuedeExactas() async {
    final android = _androidPlugin;
    if (android == null) {
      _puedeExactas = false;
      _puedeExactasAt = DateTime.now();
      return false;
    }
    _puedeExactas = await android.canScheduleExactNotifications() ?? false;
    _puedeExactasAt = DateTime.now();
    return _puedeExactas;
  }

  /// Valor de [_puedeExactas] vigente, refrescándolo solo si venció.
  Future<bool> _puedeExactasCacheado() async {
    final resuelto = _puedeExactasAt;
    if (resuelto != null &&
        DateTime.now().difference(resuelto) < _vigenciaPuedeExactas) {
      return _puedeExactas;
    }
    return _refrescarPuedeExactas();
  }

  /// Programa la notificación en el [modo] indicado.
  Future<void> _zonedSchedule({
    required int notificationId,
    required String titulo,
    required String cuerpo,
    required tz.TZDateTime cuando,
    required AndroidScheduleMode modo,
    String? payload,
  }) => _plugin.zonedSchedule(
    id: notificationId,
    title: titulo,
    body: cuerpo,
    scheduledDate: cuando,
    notificationDetails: NotificationDetails(
      android: _androidDetailsFor(NotificationChannel.agenda),
    ),
    androidScheduleMode: modo,
    payload: payload,
  );

  /// Traduce el canal del dominio a la configuración concreta de Android.
  AndroidNotificationDetails _androidDetailsFor(NotificationChannel canal) {
    return switch (canal) {
      NotificationChannel.agenda => const AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      NotificationChannel.emergencias => const AndroidNotificationDetails(
        _channelEmergenciaId,
        _channelEmergenciaName,
        importance: Importance.max,
        priority: Priority.max,
      ),
    };
  }
}
