import 'package:care_well_app/domain/entities/entities.dart';

abstract class AuthRepository {
  Future<Usuario> login(String email, String contrasena);

  Future<void> register({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    required String email,
    String? telefono,
    required String contrasena,
  });

  Future<void> solicitarRecuperacionContrasena(String email);

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

  // TODO: reemplazar por ApiAuthDatasource cuando el backend tenga el endpoint de activación de credenciales
  Future<Usuario> crearCredenciales({
    required String email,
    required String contrasena,
  });

  Future<Usuario> actualizarPerfil({
    required int usuarioId,
    String? email,
    String? telefono,
    String? documento,
  });
}
