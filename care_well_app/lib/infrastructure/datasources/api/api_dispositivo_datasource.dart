import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:dio/dio.dart';

/// Implementación de [DispositivoDatasource] contra la API REST del backend.
///
/// Ambos endpoints responden 200 sin cuerpo, así que no hay nada que
/// deserializar (por eso no existe un model de dispositivo).
class ApiDispositivoDatasource implements DispositivoDatasource {
  final Dio _dio;

  ApiDispositivoDatasource(this._dio);

  @override
  Future<void> registrar({
    required String token,
    required int plataforma,
  }) async {
    try {
      await _dio.post(
        ApiConfig.registrarDispositivoPath,
        data: {'token': token, 'plataforma': plataforma},
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> eliminar({required String token}) async {
    try {
      await _dio.post(
        ApiConfig.eliminarDispositivoPath,
        data: {'token': token},
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
