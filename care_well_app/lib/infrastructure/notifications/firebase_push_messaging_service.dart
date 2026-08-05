import 'package:firebase_messaging/firebase_messaging.dart';

import '../../domain/notifications/notifications.dart';

/// Implementación de [PushMessagingService] sobre Firebase Cloud Messaging.
///
/// Es la ÚNICA clase del proyecto que importa `firebase_messaging`: traduce
/// cada [RemoteMessage] del SDK a un [PushMessage] del dominio.
///
/// No registra un background handler a propósito: el backend envía payload
/// `notification`, así que Android muestra el aviso por su cuenta con la app en
/// background o cerrada. Solo haría falta si se pasara a mensajes data-only.
class FirebasePushMessagingService implements PushMessagingService {
  final FirebaseMessaging _messaging;

  FirebasePushMessagingService([FirebaseMessaging? messaging])
    : _messaging = messaging ?? FirebaseMessaging.instance;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> obtenerToken() => _messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<PushMessage> get onMessage =>
      FirebaseMessaging.onMessage.map(_toPushMessage);

  @override
  Stream<PushMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(_toPushMessage);

  @override
  Future<PushMessage?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _toPushMessage(message);
  }

  /// Mapea el mensaje del SDK al del dominio.
  ///
  /// FCM entrega el `data` como `Map<String, dynamic>` aunque sus valores
  /// siempre son texto: se normaliza a `Map<String, String>`.
  PushMessage _toPushMessage(RemoteMessage message) {
    return PushMessage(
      titulo: message.notification?.title,
      cuerpo: message.notification?.body,
      datos: message.data.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );
  }
}
