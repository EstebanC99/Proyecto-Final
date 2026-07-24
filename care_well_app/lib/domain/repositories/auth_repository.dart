import 'package:care_well_app/domain/entities/entities.dart';

abstract class AuthRepository {
  Future<Usuario> login(String email, String contrasena);

  Future<void> register(RegistroData data);

  Future<void> solicitarRecuperacionContrasena(String email);

  /// Confirma el restablecimiento de contraseña con el código OTP y establece
  /// la nueva contraseña. Revoca sesiones activas en otros dispositivos; no
  /// inicia sesión.
  Future<void> confirmarResetContrasena({
    required String email,
    required String codigo,
    required String contrasenaNueva,
  });

  /// Reenvía (o envía manualmente) el código de verificación de email.
  Future<void> reenviarCodigoVerificacion(String email);

  /// Verifica el email de la cuenta con el código OTP recibido.
  Future<void> verificarEmail(String email, String codigo);

  Future<void> logout();

  Future<void> eliminarCuenta(int usuarioId);

  Future<void> cambiarContrasena({
    required int usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  });

  /// Crea las credenciales de acceso de una Persona preexistente (US-04).
  ///
  /// [imagenDocumento] es la foto del documento en base64 estándar (sin prefijo
  /// data-URI). El Usuario queda pendiente de validación de email; no inicia
  /// sesión.
  Future<void> crearCredenciales({
    required String email,
    required String contrasena,
    required String imagenDocumento,
  });

  Future<Usuario> actualizarPerfil({
    required int usuarioId,
    String? email,
    String? telefono,
    String? documento,
  });
}
