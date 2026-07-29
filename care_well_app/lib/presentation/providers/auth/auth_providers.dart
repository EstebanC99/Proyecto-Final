import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../di_providers.dart';

/// Notifier que gestiona el estado de la sesión activa.
///
/// Estado `null` significa que no hay usuario autenticado.
class AuthNotifier extends StateNotifier<AsyncValue<Usuario?>> {
  AuthNotifier(this._authRepository) : super(const AsyncValue.data(null));

  final AuthRepository _authRepository;

  Future<void> login(String email, String contrasena) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authRepository.login(email, contrasena),
    );
  }

  /// Registra una nueva cuenta.
  ///
  /// En caso de éxito NO inicia sesión automáticamente: el usuario debe
  /// dirigirse al login. No modifica el estado de sesión.
  Future<AsyncValue<void>> register(RegistroData data) async {
    return AsyncValue.guard(() => _authRepository.register(data));
  }

  /// Crea credenciales para una persona preexistente sin acceso (US-04).
  ///
  /// [imagenDocumento] es la foto del documento en base64 para validar la
  /// identidad. En caso de éxito NO inicia sesión: el Usuario queda pendiente
  /// de validación de email y debe verificarlo antes de loguearse.
  Future<AsyncValue<void>> crearCredenciales({
    required String email,
    required String contrasena,
    required String imagenDocumento,
  }) async {
    return AsyncValue.guard(
      () => _authRepository.crearCredenciales(
        email: email,
        contrasena: contrasena,
        imagenDocumento: imagenDocumento,
      ),
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AsyncValue.data(null);
  }

  /// Refleja en la sesión activa los cambios de datos de la persona propia.
  void actualizarPersonaEnSesion(Persona persona) {
    final usuario = state.value;
    if (usuario == null) return;
    state = AsyncValue.data(usuario.copyWith(persona: persona));
  }

  /// Cambia la contraseña. La sesión continúa activa tras el cambio.
  ///
  /// Lanza excepción si la contraseña actual es incorrecta.
  Future<void> cambiarContrasena({
    required String contrasenaActual,
    required String nuevaContrasena,
  }) async {
    await _authRepository.cambiarContrasena(
      usuarioId: state.value!.id,
      contrasenaActual: contrasenaActual,
      contrasenaNueva: nuevaContrasena,
    );
    // No modifica state: la sesión sigue activa.
  }

  /// Elimina la cuenta del usuario en sesión.
  ///
  /// Deja el estado en [AsyncValue.data(null)] para que el redirect del
  /// router lleve al usuario al login automáticamente.
  Future<void> eliminarCuenta() async {
    await _authRepository.eliminarCuenta();
    state = const AsyncValue.data(null);
  }
}

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<Usuario?>>(
      (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
    );

/// Provider autoDispose para solicitar recuperación de contraseña.
///
/// No toca la sesión activa. Se dispara con [solicitarRecuperacionContrasenaProvider].
final solicitarRecuperacionContrasenaProvider =
    Provider.autoDispose<Future<void> Function(String email)>((ref) {
      final repo = ref.watch(authRepositoryProvider);
      return (String email) => repo.solicitarRecuperacionContrasena(email);
    });

/// Provider autoDispose para reenviar (o enviar) el código de verificación.
///
/// No toca la sesión activa. La pantalla maneja loading/error en su State.
final reenviarCodigoVerificacionProvider =
    Provider.autoDispose<Future<void> Function(String email)>((ref) {
      final repo = ref.watch(authRepositoryProvider);
      return (String email) => repo.reenviarCodigoVerificacion(email);
    });

/// Provider autoDispose para verificar el email con el código OTP.
///
/// No toca la sesión activa (el backend no auto-loguea): tras verificar OK,
/// el usuario debe iniciar sesión normalmente.
final verificarEmailProvider =
    Provider.autoDispose<Future<void> Function(String email, String codigo)>((
      ref,
    ) {
      final repo = ref.watch(authRepositoryProvider);
      return (String email, String codigo) =>
          repo.verificarEmail(email, codigo);
    });

/// Provider autoDispose para confirmar el restablecimiento de contraseña con
/// el código OTP y la nueva contraseña.
///
/// No toca la sesión activa: el backend cambia la contraseña y revoca sesiones
/// en otros dispositivos, pero NO auto-loguea. La pantalla maneja
/// loading/error en su State.
final confirmarResetContrasenaProvider =
    Provider.autoDispose<
      Future<void> Function(String email, String codigo, String contrasenaNueva)
    >((ref) {
      final repo = ref.watch(authRepositoryProvider);
      return (String email, String codigo, String contrasenaNueva) =>
          repo.confirmarResetContrasena(
            email: email,
            codigo: codigo,
            contrasenaNueva: contrasenaNueva,
          );
    });
