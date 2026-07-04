import 'package:dio/dio.dart';

import '../../../domain/datasources/estado_animo_datasource.dart';
import '../../../domain/entities/entities.dart';
import '../../http/api_config.dart';
import '../../http/api_exception_mapper.dart';
import '../../mappers/health_mapper.dart';
import '../../models/health/health_models.dart';

/// Implementación de [EstadoAnimoDatasource] contra la API REST del backend.
class ApiEstadoAnimoDatasource implements EstadoAnimoDatasource {
  final Dio _dio;

  ApiEstadoAnimoDatasource(this._dio);

  @override
  Future<EstadoDeAnimo?> obtenerAnimoHoy(Persona persona) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerAnimoHoyPath,
        data: {'personaID': persona.id},
      );

      // El backend responde HTTP 200 con body null si no hay registro hoy.
      if (response.data == null) return null;

      return PersonaEstadoAnimoMapper.fromModel(
        PersonaEstadoAnimoModel.fromJson(response.data as Map<String, dynamic>),
        persona,
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<List<EstadoDeAnimo>> obtenerPorFechas({
    required Persona persona,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerAnimoPorFechasPath,
        data: {
          'personaID': persona.id,
          'fechaDesde': desde.toIso8601String(),
          'fechaHasta': hasta.toIso8601String(),
        },
      );

      return (response.data as List<dynamic>)
          .map(
            (e) => PersonaEstadoAnimoMapper.fromModel(
              PersonaEstadoAnimoModel.fromJson(e as Map<String, dynamic>),
              persona,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> registrar({
    required int personaId,
    required int estadoAnimoId,
    String? observaciones,
  }) async {
    try {
      await _dio.post(
        ApiConfig.registrarAnimoPath,
        data: {
          'personaID': personaId,
          'estadoAnimoID': estadoAnimoId,
          'observaciones': observaciones,
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
