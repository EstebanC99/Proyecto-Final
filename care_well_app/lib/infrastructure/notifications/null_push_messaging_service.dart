import '../../domain/notifications/notifications.dart';

/// Implementación inerte de [PushMessagingService] para cuando el SDK de
/// mensajería no está disponible.
///
/// Se usa si `Firebase.initializeApp()` falló en `main.dart` (por ejemplo, un
/// clone del repo sin `google-services.json`, que no se versiona). El push es
/// *best effort*: la app tiene que arrancar y ser navegable igual, simplemente
/// sin notificaciones remotas.
///
/// Es el mismo patrón que aplica el backend con `PushSenderNulo` cuando no hay
/// credenciales de Firebase configuradas.
///
/// Al devolver `null` en [obtenerToken], el `PushTokenSynchronizer` corta solo:
/// no da de alta ni de baja ningún dispositivo contra el backend.
class NullPushMessagingService implements PushMessagingService {
  const NullPushMessagingService();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String?> obtenerToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<PushMessage> get onMessage => const Stream.empty();

  @override
  Stream<PushMessage> get onMessageOpenedApp => const Stream.empty();

  @override
  Future<PushMessage?> getInitialMessage() async => null;
}
