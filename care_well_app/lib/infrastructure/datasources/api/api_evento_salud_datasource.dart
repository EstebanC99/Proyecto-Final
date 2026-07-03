import 'package:care_well_app/domain/datasources/evento_salud_datasource.dart';
import 'package:care_well_app/domain/entities/health/evento_de_salud.dart';
import 'package:care_well_app/infrastructure/http/api_config.dart';
import 'package:care_well_app/infrastructure/http/api_exception_mapper.dart';
import 'package:care_well_app/infrastructure/mappers/health_mapper.dart';
import 'package:care_well_app/infrastructure/models/health/health_models.dart';
import 'package:dio/dio.dart';

/// Implementación de [EventoSaludDatasource] contra la API REST del backend.
class ApiEventoSaludDatasource implements EventoSaludDatasource {
  final Dio _dio;

  ApiEventoSaludDatasource(this._dio);

  @override
  Future<List<EventoDeSalud>> getEventosSaludDelMes({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerEventosSaludPath,
        data: {
          'personaID': personaId,
          'fechaDesde': desde.toIso8601String(),
          'fechaHasta': hasta.toIso8601String(),
        },
      );

      return (response.data as List<dynamic>)
          .map(
            (e) => EventoDeSaludMapper.fromModel(
              EventoDeSaludModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> crearEventoSalud({
    required int personaId,
    required int tipoId,
    required DateTime fechaHora,
    required String descripcion,
  }) async {
    try {
      await _dio.post(
        ApiConfig.crearEventoSaludPath,
        data: {
          'personaID': personaId,
          'tipoID': tipoId,
          'fechaHora': fechaHora.toIso8601String(),
          'descripcion': descripcion,
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> eliminarEventoSalud(int eventoId) async {
    try {
      await _dio.post(ApiConfig.eliminarEventoSaludPath, data: eventoId);
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> agregarNota({
    required int eventoSaludId,
    required String contenido,
  }) async {
    try {
      await _dio.post(
        ApiConfig.agregarNotaEventoSaludPath,
        data: {'eventoSaludID': eventoSaludId, 'contenido': contenido},
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> modificarNota({
    required int eventoSaludId,
    required int notaId,
    required String contenido,
  }) async {
    try {
      await _dio.post(
        ApiConfig.modificarNotaEventoSaludPath,
        data: {
          'eventoSaludID': eventoSaludId,
          'notaID': notaId,
          'contenido': contenido,
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> eliminarNota({
    required int eventoSaludId,
    required int notaId,
  }) async {
    try {
      await _dio.post(
        ApiConfig.eliminarNotaEventoSaludPath,
        data: {'eventoSaludID': eventoSaludId, 'notaID': notaId},
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
