import '../entities/entities.dart';

/// Interfaz de datasource para autenticación y gestión de cuenta.
abstract class AuthDatasource {
  /// Inicia sesión con [nombreUsuario] y [contrasena].
  ///
  /// Retorna el [Usuario] autenticado.
  /// Lanza excepción si las credenciales son inválidas.
  Future<Usuario> login(String nombreUsuario, String contrasena);

  /// Registra un nuevo usuario y la persona asociada.
  ///
  /// Retorna el [Usuario] creado.
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

  /// Crea credenciales de acceso para una [Persona] que ya existe en el sistema
  /// pero aún no tiene [Usuario] asociado (fue cargada por un responsable/cuidador).
  ///
  /// Lanza excepción si la persona no existe o si ya tiene credenciales.
  Future<Usuario> crearCredenciales({
    required String email,
    required String nombreUsuario,
    required String contrasena,
  });

  /// Actualiza los datos de perfil del usuario identificado por [usuarioId].
  ///
  /// Solo se actualizan los campos que sean no-null. Retorna el [Usuario] actualizado.
  Future<Usuario> actualizarPerfil({
    required String usuarioId,
    String? email,
    String? telefono,
    String? documento,
  });
}
