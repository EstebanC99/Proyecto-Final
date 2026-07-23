import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

/// Datasource falso que registra las llamadas de verificación de email para
/// comprobar que [AuthRepositoryImpl] delega correctamente.
class _FakeAuthDatasource implements AuthDatasource {
  String? reenviarCodigoEmail;
  ({String email, String codigo})? verificarEmailArgs;
  ({String email, String codigo, String contrasenaNueva})?
  confirmarResetContrasenaArgs;

  @override
  Future<void> reenviarCodigoVerificacion(String email) async {
    reenviarCodigoEmail = email;
  }

  @override
  Future<void> verificarEmail(String email, String codigo) async {
    verificarEmailArgs = (email: email, codigo: codigo);
  }

  @override
  Future<void> confirmarResetContrasena({
    required String email,
    required String codigo,
    required String contrasenaNueva,
  }) async {
    confirmarResetContrasenaArgs = (
      email: email,
      codigo: codigo,
      contrasenaNueva: contrasenaNueva,
    );
  }

  // ── Resto de la interfaz: no usado en estos tests ──────────────────────────
  @override
  Future<Usuario> login(String email, String contrasena) =>
      throw UnimplementedError();

  @override
  Future<void> register({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    required String email,
    String? telefono,
    required String contrasena,
  }) => throw UnimplementedError();

  @override
  Future<void> solicitarRecuperacionContrasena(String email) =>
      throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

  @override
  Future<void> eliminarCuenta(int usuarioId) => throw UnimplementedError();

  @override
  Future<void> cambiarContrasena({
    required int usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  }) => throw UnimplementedError();

  @override
  Future<Usuario> crearCredenciales({
    required String email,
    required String contrasena,
  }) => throw UnimplementedError();

  @override
  Future<Usuario> actualizarPerfil({
    required int usuarioId,
    String? email,
    String? telefono,
    String? documento,
  }) => throw UnimplementedError();
}

void main() {
  group('AuthRepositoryImpl (verificación de email)', () {
    test(
      'reenviarCodigoVerificacion delega el email en el datasource',
      () async {
        final datasource = _FakeAuthDatasource();
        final repository = AuthRepositoryImpl(datasource);

        await repository.reenviarCodigoVerificacion('test@example.com');

        expect(datasource.reenviarCodigoEmail, 'test@example.com');
      },
    );

    test('verificarEmail delega email y código en el datasource', () async {
      final datasource = _FakeAuthDatasource();
      final repository = AuthRepositoryImpl(datasource);

      await repository.verificarEmail('test@example.com', '654321');

      expect(datasource.verificarEmailArgs?.email, 'test@example.com');
      expect(datasource.verificarEmailArgs?.codigo, '654321');
    });

    test('confirmarResetContrasena delega email, código y contraseña en el '
        'datasource', () async {
      final datasource = _FakeAuthDatasource();
      final repository = AuthRepositoryImpl(datasource);

      await repository.confirmarResetContrasena(
        email: 'test@example.com',
        codigo: '654321',
        contrasenaNueva: 'NuevaClave8',
      );

      expect(
        datasource.confirmarResetContrasenaArgs?.email,
        'test@example.com',
      );
      expect(datasource.confirmarResetContrasenaArgs?.codigo, '654321');
      expect(
        datasource.confirmarResetContrasenaArgs?.contrasenaNueva,
        'NuevaClave8',
      );
    });
  });
}
