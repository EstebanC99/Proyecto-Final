import 'package:care_well_app/domain/datasources/linea_tiempo_salud_datasource.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:dio/dio.dart';

/// Implementación de [LineaTiempoSaludDatasource] contra la API REST del backend.
class ApiLineaTiempoSaludDatasource implements LineaTiempoSaludDatasource {
  final Dio _dio;

  ApiLineaTiempoSaludDatasource(this._dio);

  @override
  Future<List<EventoBase>> getEventosPorFechas({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerLineaTiempoSaludPath,
        data: {
          'personaID': personaId,
          'fechaDesde': desde.toIso8601String(),
          'fechaHasta': hasta.toIso8601String(),
        },
      );

      return (response.data as List<dynamic>)
          .map(
            (e) => EventoBaseMapper.fromModel(
              EventoBaseModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
