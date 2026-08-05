import 'push_message.dart';

/// Contrato del servicio de notificaciones push (remotas).
///
/// Se distingue de [NotificationScheduler], que programa notificaciones
/// LOCALES en el dispositivo: acá los mensajes los origina el backend.
///
/// La inicialización del SDK del proveedor ocurre en `main.dart`, por lo que
/// este contrato no expone un `init()`. Cuando se sume iOS habrá que agregarlo
/// para configurar la presentación en foreground.
abstract class PushMessagingService {
  /// Solicita al usuario permiso para mostrar notificaciones.
  ///
  /// Retorna `true` si quedó autorizado.
  Future<bool> requestPermission();

  /// Token de registro de ESTA instalación, o `null` si no se pudo obtener
  /// (por ejemplo, en un dispositivo sin Google Play Services).
  Future<String?> obtenerToken();

  /// Emite el nuevo token cada vez que el proveedor lo rota.
  Stream<String> get onTokenRefresh;

  /// Mensajes recibidos con la app en primer plano.
  ///
  /// En Android el sistema NO muestra la notificación en este caso: hay que
  /// renderizarla manualmente.
  Stream<PushMessage> get onMessage;

  /// Mensajes cuya notificación tocó el usuario estando la app en background.
  Stream<PushMessage> get onMessageOpenedApp;

  /// Mensaje que abrió la app desde el estado terminado, si hubo uno.
  Future<PushMessage?> getInitialMessage();
}
