import 'package:care_well_app/domain/entities/entities.dart';

abstract class AuthDatasource {
  Future<Usuario> login(String email, String contrasena);

  Future<void> register(RegistroData data);

  Future<void> solicitarRecuperacionContrasena(String email);

  Future<void> confirmarResetContrasena({
    required String email,
    required String codigo,
    required String contrasenaNueva,
  });

  Future<void> reenviarCodigoVerificacion(String email);

  Future<void> verificarEmail(String email, String codigo);

  Future<void> logout();

  Future<void> eliminarCuenta();

  Future<void> cambiarContrasena({
    required int usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  });

  Future<void> crearCredenciales({
    required String email,
    required String contrasena,
    required String imagenDocumento,
  });
}
