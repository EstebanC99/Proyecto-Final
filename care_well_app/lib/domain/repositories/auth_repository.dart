import '../entities/entities.dart';

/// Contrato de repositorio para autenticación y gestión de cuenta.
///
/// El repositorio orquesta uno o más datasources y representa el punto
/// de acceso que la capa de presentación utiliza para las operaciones de auth.
abstract class AuthRepository {
  /// Inicia sesión con [email] y [contrasena].
  Future<Usuario> login(String email, String contrasena);

  /// Registra un nuevo usuario y la persona asociada.
  ///
  /// No inicia sesión: tras el alta el usuario debe loguearse manualmente.
  Future<void> register({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    required String email,
    String? telefono,
    required String contrasena,
  });

  /// Solicita el restablecimiento de contraseña para [email].
  Future<void> solicitarRecuperacionContrasena(String email);

  /// Cierra la sesión actual.
  Future<void> logout();

  /// Elimina la cuenta del usuario autenticado.
  Future<void> eliminarCuenta(int usuarioId);

  /// Cambia la contraseña del usuario autenticado.
  Future<void> cambiarContrasena({
    required int usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  });

  /// Crea credenciales de acceso para una [Persona] preexistente sin [Usuario].
  // TODO: reemplazar por ApiAuthDatasource cuando el backend tenga el endpoint de activación de credenciales
  Future<Usuario> crearCredenciales({
    required String email,
    required String contrasena,
  });

  /// Actualiza los datos de perfil del usuario identificado por [usuarioId].
  ///
  /// Solo se actualizan los campos no-null. Retorna el [Usuario] actualizado.
  Future<Usuario> actualizarPerfil({
    required int usuarioId,
    String? email,
    String? telefono,
    String? documento,
  });
}
