import '../entities/entities.dart';

/// Contrato de repositorio para autenticación y gestión de cuenta.
///
/// El repositorio orquesta uno o más datasources y representa el punto
/// de acceso que la capa de presentación utiliza para las operaciones de auth.
abstract class AuthRepository {
  /// Inicia sesión con [nombreUsuario] y [contrasena].
  Future<Usuario> login(String nombreUsuario, String contrasena);

  /// Registra un nuevo usuario y la persona asociada.
  Future<Usuario> register({
    required String nombre,
    required String apellido,
    required String email,
    required String nombreUsuario,
    required String contrasena,
  });

  /// Solicita el restablecimiento de contraseña para [email].
  Future<void> solicitarRecuperacionContrasena(String email);

  /// Cierra la sesión actual.
  Future<void> logout();

  /// Elimina la cuenta del usuario autenticado.
  Future<void> eliminarCuenta(String usuarioId);

  /// Cambia la contraseña del usuario autenticado.
  Future<void> cambiarContrasena({
    required String usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  });

  /// Crea credenciales de acceso para una [Persona] preexistente sin [Usuario].
  Future<Usuario> crearCredenciales({
    required String email,
    required String nombreUsuario,
    required String contrasena,
  });

  /// Actualiza los datos de perfil del usuario identificado por [usuarioId].
  ///
  /// Solo se actualizan los campos no-null. Retorna el [Usuario] actualizado.
  Future<Usuario> actualizarPerfil({
    required String usuarioId,
    String? email,
    String? telefono,
    String? documento,
  });
}
