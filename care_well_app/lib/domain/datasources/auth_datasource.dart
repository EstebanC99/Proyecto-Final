import 'package:care_well_app/domain/entities/entities.dart';

abstract class AuthDatasource {
  Future<Usuario> login(String email, String contrasena);

  Future<void> register(RegistroData data);

  Future<void> solicitarRecuperacionContrasena(String email);

  /// Confirma el restablecimiento de contraseña con el código OTP recibido y
  /// establece la nueva contraseña.
  ///
  /// En caso de éxito el backend cambia la contraseña y revoca las sesiones
  /// activas en otros dispositivos. NO inicia sesión: el usuario debe
  /// loguearse normalmente después.
  Future<void> confirmarResetContrasena({
    required String email,
    required String codigo,
    required String contrasenaNueva,
  });

  /// Reenvía (o envía manualmente) el código de verificación de email.
  ///
  /// El backend aplica cooldown y tope de envíos; si se excede responde con
  /// error de validación. Si el email no existe, responde OK igualmente
  /// (anti-enumeración).
  Future<void> reenviarCodigoVerificacion(String email);

  /// Verifica el email de la cuenta con el código OTP recibido.
  ///
  /// En caso de éxito la cuenta pasa a estado activo, pero NO se inicia sesión:
  /// el usuario debe loguearse normalmente después.
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
  /// data-URI), usada por el backend para validar la identidad. El endpoint
  /// responde sin cuerpo: el Usuario queda en estado pendiente de validación y
  /// se dispara el envío del código OTP. No inicia sesión.
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
