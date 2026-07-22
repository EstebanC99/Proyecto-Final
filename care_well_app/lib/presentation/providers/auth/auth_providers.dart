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
  Future<AsyncValue<void>> register({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    required String email,
    String? telefono,
    required String contrasena,
  }) async {
    return AsyncValue.guard(
      () => _authRepository.register(
        nombre: nombre,
        apellido: apellido,
        documento: documento,
        fechaNacimiento: fechaNacimiento,
        email: email,
        telefono: telefono,
        contrasena: contrasena,
      ),
    );
  }

  /// Crea credenciales para una persona preexistente sin acceso.
  ///
  /// En caso de éxito NO inicia sesión: el usuario debe ir al login.
  // TODO: reemplazar por ApiAuthDatasource cuando el backend tenga el endpoint de activación de credenciales
  Future<AsyncValue<Usuario>> crearCredenciales({
    required String email,
    required String contrasena,
  }) async {
    return AsyncValue.guard(
      () => _authRepository.crearCredenciales(
        email: email,
        contrasena: contrasena,
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

  /// Actualiza el perfil del usuario en sesión y refresca el estado.
  // Reservado para el futuro endpoint de credenciales/email; no cableado a la UI.
  Future<void> actualizarPerfil({
    String? email,
    String? telefono,
    String? documento,
  }) async {
    final usuario = state.value;
    if (usuario == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authRepository.actualizarPerfil(
        usuarioId: usuario.id,
        email: email,
        telefono: telefono,
        documento: documento,
      ),
    );
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
    await _authRepository.eliminarCuenta(state.value!.id);
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
