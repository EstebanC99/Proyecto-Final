import 'dart:async';

import 'package:care_well_app/domain/notifications/notifications.dart';

/// Fake de [PushMessagingService] con control manual de los eventos del
/// proveedor: rotación del token, mensajes en foreground y aperturas por
/// notificación.
class FakePushMessagingService implements PushMessagingService {
  FakePushMessagingService({this.token, this.initialMessage});

  /// Token que devuelve [obtenerToken]. `null` simula un dispositivo sin
  /// Google Play Services.
  String? token;

  /// Mensaje que abrió la app desde el estado terminado.
  PushMessage? initialMessage;

  bool permisoSolicitado = false;

  final _tokenRefreshController = StreamController<String>.broadcast();
  final _messageController = StreamController<PushMessage>.broadcast();
  final _messageOpenedAppController = StreamController<PushMessage>.broadcast();

  /// Simula que el proveedor rotó el token.
  void rotarToken(String nuevo) {
    token = nuevo;
    _tokenRefreshController.add(nuevo);
  }

  /// Simula la llegada de un mensaje con la app en primer plano.
  void emitirMensaje(PushMessage message) => _messageController.add(message);

  /// Simula que el usuario tocó la notificación con la app en background.
  void emitirAperturaApp(PushMessage message) =>
      _messageOpenedAppController.add(message);

  Future<void> dispose() async {
    await _tokenRefreshController.close();
    await _messageController.close();
    await _messageOpenedAppController.close();
  }

  @override
  Future<bool> requestPermission() async {
    permisoSolicitado = true;
    return true;
  }

  @override
  Future<String?> obtenerToken() async => token;

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Stream<PushMessage> get onMessage => _messageController.stream;

  @override
  Stream<PushMessage> get onMessageOpenedApp =>
      _messageOpenedAppController.stream;

  @override
  Future<PushMessage?> getInitialMessage() async => initialMessage;
}
