import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:care_well_app/infrastructure/mappers/auth/usuario_mapper.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:care_well_app/infrastructure/storage/token_storage.dart';
import 'package:dio/dio.dart';

class ApiAuthDatasource implements AuthDatasource {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiAuthDatasource(this._dio, this._tokenStorage);

  LoginResponse _jsonToLoginResponse(Map<String, dynamic> json) {
    final loginResponse = LoginResponse.fromJson(json);

    return loginResponse;
  }

  @override
  Future<Usuario> login(String email, String contrasena) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginPath,
        data: {'email': email, 'contrasena': contrasena},
      );
      final loginResponse = _jsonToLoginResponse(response.data);

      await _tokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        userId: loginResponse.usuario.id,
      );

      return UsuarioMapper.fromModel(loginResponse.usuario);
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> register({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    required String email,
    String? telefono,
    required String contrasena,
  }) async {
    try {
      await _dio.post(
        ApiConfig.cuentaPath,
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'documento': documento,
          'fechaNacimiento': fechaNacimiento.toIso8601String(),
          'email': email,
          'telefono': telefono ?? '',
          'contrasena': contrasena,
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
  }

  // ── eliminarCuenta ───────────────────────────────────────────────────────────

  @override
  Future<void> eliminarCuenta(int usuarioId) async {
    // TODO: endpoint pendiente en el backend. Limpiar storage igual para
    // que la sesión quede cerrada aunque el servidor no lo procese aún.
    await _tokenStorage.clear();
    throw UnimplementedError(
      'TODO: endpoint de eliminación de cuenta pendiente en el backend.',
    );
  }

  // ── cambiarContrasena ────────────────────────────────────────────────────────

  @override
  Future<void> cambiarContrasena({
    required int usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  }) async {
    // TODO: endpoint pendiente en el backend (CuentaController o nuevo controller).
    throw UnimplementedError(
      'TODO: endpoint de cambio de contraseña pendiente en el backend.',
    );
  }

  // ── solicitarRecuperacionContrasena ──────────────────────────────────────────

  @override
  Future<void> solicitarRecuperacionContrasena(String email) async {
    // TODO: endpoint pendiente en el backend.
    throw UnimplementedError(
      'TODO: endpoint de recuperación de contraseña pendiente en el backend.',
    );
  }

  // ── crearCredenciales ────────────────────────────────────────────────────────

  @override
  Future<Usuario> crearCredenciales({
    required String email,
    required String contrasena,
  }) async {
    // TODO: endpoint pendiente en el backend (activación de credenciales para
    // una Persona preexistente cargada por un responsable/cuidador).
    throw UnimplementedError(
      'TODO: endpoint de creación de credenciales pendiente en el backend.',
    );
  }

  // ── actualizarPerfil ─────────────────────────────────────────────────────────

  @override
  Future<Usuario> actualizarPerfil({
    required int usuarioId,
    String? email,
    String? telefono,
    String? documento,
  }) async {
    // TODO: endpoint pendiente en el backend.
    throw UnimplementedError(
      'TODO: endpoint de actualización de perfil pendiente en el backend.',
    );
  }
}
