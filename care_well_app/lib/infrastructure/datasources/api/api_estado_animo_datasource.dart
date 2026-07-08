import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:dio/dio.dart';

/// Implementación de [EstadoAnimoDatasource] contra la API REST del backend.
class ApiEstadoAnimoDatasource implements EstadoAnimoDatasource {
  final Dio _dio;

  ApiEstadoAnimoDatasource(this._dio);

  @override
  Future<PersonaEstadoAnimo?> obtenerAnimoHoy(Persona persona) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerAnimoHoyPath,
        data: {'personaID': persona.id},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) return null;

      return PersonaEstadoAnimoMapper.fromModel(
        PersonaEstadoAnimoModel.fromJson(data),
        persona,
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<List<PersonaEstadoAnimo>> obtenerPorFechas({
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
