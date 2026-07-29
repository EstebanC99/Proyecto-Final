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
  Future<void> register(RegistroData data) async {
    try {
      await _dio.post(
        ApiConfig.cuentaPath,
        data: {
          'nombre': data.nombre,
          'apellido': data.apellido,
          'documento': data.documento,
          'fechaNacimiento': data.fechaNacimiento.toIso8601String(),
          'email': data.email,
          'telefono': data.telefono ?? '',
          'contrasena': data.contrasena,
          'imagenDocumento': data.imagenDocumento,
          'imagen': ?data.imagen,
        },
        options: Options(
          receiveTimeout: ApiConfig.receiveTimeoutValidacionIdentidad,
        ),
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> reenviarCodigoVerificacion(String email) async {
    try {
      await _dio.post(ApiConfig.reenviarCodigoPath, data: {'email': email});
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> verificarEmail(String email, String codigo) async {
    try {
      await _dio.post(
        ApiConfig.verificarEmailPath,
        data: {'email': email, 'codigo': codigo},
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
  }

  @override
  Future<void> eliminarCuenta() async {
    try {
      await _dio.post(
        ApiConfig.eliminarCuentaPath
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

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

  @override
  Future<void> solicitarRecuperacionContrasena(String email) async {
    try {
      await _dio.post(
        ApiConfig.solicitarResetContrasenaPath,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> confirmarResetContrasena({
    required String email,
    required String codigo,
    required String contrasenaNueva,
  }) async {
    try {
      await _dio.post(
        ApiConfig.confirmarResetContrasenaPath,
        data: {
          'email': email,
          'codigo': codigo,
          'contrasenaNueva': contrasenaNueva,
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> crearCredenciales({
    required String email,
    required String contrasena,
    required String imagenDocumento,
  }) async {
    try {
      await _dio.post(
        ApiConfig.crearCredencialesPath,
        data: {
          'email': email,
          'contrasena': contrasena,
          'imagenDocumento': imagenDocumento,
        },
        options: Options(
          receiveTimeout: ApiConfig.receiveTimeoutValidacionIdentidad,
        ),
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
