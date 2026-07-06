import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:dio/dio.dart';

/// Implementación de [HabitoVidaDatasource] contra la API REST del backend.
class ApiHabitoVidaDatasource implements HabitoVidaDatasource {
  final Dio _dio;

  ApiHabitoVidaDatasource(this._dio);

  @override
  Future<List<HabitoVida>> getHabitosByPersona(int personaId) async {
    try {
      final hoy = DateTime.now();
      final desde = DateTime(hoy.year, hoy.month, hoy.day);
      final hasta = desde.add(const Duration(days: 1));

      final response = await _dio.post(
        ApiConfig.obtenerHabitosPath,
        data: {
          'personaID': personaId,
          'fechaDesde': desde.toIso8601String(),
          'fechaHasta': hasta.toIso8601String(),
        },
      );

      return (response.data as List<dynamic>)
          .map(
            (e) => HabitoVidaMapper.fromModel(
              HabitoVidaModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> crearHabito({
    required int personaId,
    required int tipoId,
    required String descripcion,
  }) async {
    try {
      await _dio.post(
        ApiConfig.crearHabitoPath,
        data: {
          'personaID': personaId,
          'tipoHabitoID': tipoId,
          'descripcion': descripcion,
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> modificarHabito({
    required int habitoId,
    required int tipoId,
    required String descripcion,
  }) async {
    try {
      await _dio.post(
        ApiConfig.modificarHabitoPath,
        data: {
          'habitoVidaID': habitoId,
          'tipoHabitoID': tipoId,
          'descripcion': descripcion,
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> eliminarHabito(int habitoId) async {
    try {
      await _dio.post(ApiConfig.eliminarHabitoPath, data: habitoId);
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> crearRealizacion({
    required int habitoId,
    String? comentarios,
  }) async {
    try {
      await _dio.post(
        ApiConfig.crearRealizacionHabitoPath,
        data: {'habitoVidaID': habitoId, 'comentarios': comentarios},
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> modificarRealizacion({
    required int habitoId,
    required int realizacionId,
    String? comentarios,
  }) async {
    try {
      await _dio.post(
        ApiConfig.modificarRealizacionHabitoPath,
        data: {
          'habitoVidaID': habitoId,
          'realizacionID': realizacionId,
          'comentarios': comentarios,
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> eliminarRealizacion({
    required int habitoId,
    required int realizacionId,
  }) async {
    try {
      await _dio.post(
        ApiConfig.eliminarRealizacionHabitoPath,
        data: {'habitoVidaID': habitoId, 'realizacionID': realizacionId},
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
