import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/notifications/notifications.dart';
import '../../../domain/repositories/repositories.dart';
import '../auth/auth_providers.dart';
import '../di_providers.dart';

/// Mantiene sincronizado el token push de ESTA instalación con el backend.
///
/// Responsabilidad única: dar de alta el dispositivo cuando hay sesión y darlo
/// de baja al cerrarla. Todas las operaciones son *best effort*: una falla de
/// red no debe romper el login ni impedir el logout, porque el aviso de
/// emergencia no es un canal garantizado.
class PushTokenSynchronizer {
  final PushMessagingService _pushMessaging;
  final DispositivoRepository _dispositivoRepository;

  PushTokenSynchronizer(this._pushMessaging, this._dispositivoRepository);

  /// Alta en curso. Se espera antes de dar de baja para que el backend no
  /// procese el registro DESPUÉS de la baja y reactive el dispositivo.
  Future<void>? _altaEnCurso;

  /// Emite el nuevo token cada vez que el proveedor lo rota.
  Stream<String> get onTokenRefresh => _pushMessaging.onTokenRefresh;

  /// Pide permiso de notificaciones, obtiene el token y lo registra.
  ///
  /// Sin permiso el token igual se registra: el usuario puede habilitar las
  /// notificaciones más tarde desde los ajustes del sistema y el dispositivo ya
  /// quedaría listo.
  Future<void> registrarDispositivo() {
    final alta = _registrarDispositivo();
    _altaEnCurso = alta;
    return alta;
  }

  Future<void> _registrarDispositivo() async {
    await _pushMessaging.requestPermission();
    final token = await _pushMessaging.obtenerToken();
    if (token == null) return;
    await registrarToken(token);
  }

  /// Registra un token ya conocido (alta inicial o rotación).
  Future<void> registrarToken(String token) {
    return _dispositivoRepository.registrar(
      token: token,
      plataforma: PlataformasDispositivoConst.android,
    );
  }

  /// Da de baja el dispositivo. Requiere que la sesión siga activa.
  ///
  /// Espera el alta en curso: el alta es fire-and-forget, así que sin esta
  /// espera un logout inmediato podría llegar al backend antes que el registro
  /// y dejar el dispositivo activo para un usuario que ya cerró sesión.
  Future<void> darDeBajaDispositivo() async {
    // Nunca dejar que una falla del alta impida la baja.
    try {
      await _altaEnCurso;
    } catch (_) {}
    _altaEnCurso = null;

    final token = await _pushMessaging.obtenerToken();
    if (token == null) return;
    await _dispositivoRepository.eliminar(token: token);
  }
}

final pushTokenSynchronizerProvider = Provider<PushTokenSynchronizer>(
  (ref) => PushTokenSynchronizer(
    ref.watch(pushMessagingServiceProvider),
    ref.watch(dispositivoRepositoryProvider),
  ),
);

/// Registra el dispositivo mientras haya sesión activa y lo mantiene al día
/// ante rotaciones del token.
///
/// Se reconstruye en cada cambio de sesión: al cerrarla, `ref.onDispose`
/// cancela la suscripción a `onTokenRefresh`. Hay que mantenerlo vivo con un
/// `ref.watch` desde `CareWellApp` (no desde una pantalla suelta).
final pushTokenRegistrationProvider = Provider<void>((ref) {
  final usuario = ref.watch(authStateProvider).value;
  if (usuario == null) return;

  final synchronizer = ref.watch(pushTokenSynchronizerProvider);

  // Fire-and-forget: el alta no debe bloquear la navegación post-login.
  synchronizer.registrarDispositivo().catchError((_) {
    // Best effort: si el backend no responde, se reintenta en el próximo login.
  });

  final subscription = synchronizer.onTokenRefresh.listen((token) {
    synchronizer.registrarToken(token).catchError((_) {});
  });
  ref.onDispose(subscription.cancel);
});
