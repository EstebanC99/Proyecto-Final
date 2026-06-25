import '../../domain/datasources/datasources.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

/// Implementación de [AuthRepository] que delega al [AuthDatasource] inyectado.
class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;

  const AuthRepositoryImpl(this._datasource);

  @override
  Future<Usuario> login(String email, String contrasena) =>
      _datasource.login(email, contrasena);

  @override
  Future<void> register({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    required String email,
    String? telefono,
    required String contrasena,
  }) => _datasource.register(
    nombre: nombre,
    apellido: apellido,
    documento: documento,
    fechaNacimiento: fechaNacimiento,
    email: email,
    telefono: telefono,
    contrasena: contrasena,
  );

  @override
  Future<void> solicitarRecuperacionContrasena(String email) =>
      _datasource.solicitarRecuperacionContrasena(email);

  @override
  Future<void> logout() => _datasource.logout();

  @override
  Future<void> eliminarCuenta(int usuarioId) =>
      _datasource.eliminarCuenta(usuarioId);

  @override
  Future<void> cambiarContrasena({
    required int usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  }) => _datasource.cambiarContrasena(
    usuarioId: usuarioId,
    contrasenaActual: contrasenaActual,
    contrasenaNueva: contrasenaNueva,
  );

  @override
  Future<Usuario> crearCredenciales({
    required String email,
    required String contrasena,
  }) => _datasource.crearCredenciales(email: email, contrasena: contrasena);

  @override
  Future<Usuario> actualizarPerfil({
    required int usuarioId,
    String? email,
    String? telefono,
    String? documento,
  }) => _datasource.actualizarPerfil(
    usuarioId: usuarioId,
    email: email,
    telefono: telefono,
    documento: documento,
  );
}
