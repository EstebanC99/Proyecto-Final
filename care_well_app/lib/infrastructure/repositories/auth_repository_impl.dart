import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;

  const AuthRepositoryImpl(this._datasource);

  @override
  Future<Usuario> login(String email, String contrasena) =>
      _datasource.login(email, contrasena);

  @override
  Future<void> register(RegistroData data) => _datasource.register(data);

  @override
  Future<void> solicitarRecuperacionContrasena(String email) =>
      _datasource.solicitarRecuperacionContrasena(email);

  @override
  Future<void> confirmarResetContrasena({
    required String email,
    required String codigo,
    required String contrasenaNueva,
  }) => _datasource.confirmarResetContrasena(
    email: email,
    codigo: codigo,
    contrasenaNueva: contrasenaNueva,
  );

  @override
  Future<void> reenviarCodigoVerificacion(String email) =>
      _datasource.reenviarCodigoVerificacion(email);

  @override
  Future<void> verificarEmail(String email, String codigo) =>
      _datasource.verificarEmail(email, codigo);

  @override
  Future<void> logout() => _datasource.logout();

  @override
  Future<void> eliminarCuenta() => _datasource.eliminarCuenta();

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
  Future<void> crearCredenciales({
    required String email,
    required String contrasena,
    required String imagenDocumento,
  }) => _datasource.crearCredenciales(
    email: email,
    contrasena: contrasena,
    imagenDocumento: imagenDocumento,
  );
}
