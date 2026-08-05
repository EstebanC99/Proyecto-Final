import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:dio/dio.dart';

/// Implementación de [EmergencyDatasource] contra la API REST del backend.
///
/// El backend registra la emergencia y envía el aviso push al equipo de
/// cuidado, excluyendo al activador y a la persona cuidada.
class ApiEmergencyDatasource implements EmergencyDatasource {
  final Dio _dio;

  ApiEmergencyDatasource(this._dio);

  @override
  Future<void> activarEmergencia({
    required int personaId,
    String? descripcion,
  }) async {
    try {
      // El endpoint responde 200 sin cuerpo: no hay nada que parsear.
      await _dio.post(
        ApiConfig.activarEmergenciaPath,
        data: {'personaID': personaId, 'descripcion': descripcion},
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<List<Emergencia>> getEmergenciasByPersona(
    int personaId, {
    int cantidad = 20,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerEmergenciasPath,
        data: {'personaID': personaId, 'cantidad': cantidad},
      );

      return (response.data as List<dynamic>)
          .map(
            (e) => EmergenciaMapper.fromModel(
              EmergenciaModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
