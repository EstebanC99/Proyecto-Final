import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:dio/dio.dart';

/// Implementación de [ResumenSaludDatasource] contra la API REST del backend.
class ApiResumenSaludDatasource implements ResumenSaludDatasource {
  final Dio _dio;

  ApiResumenSaludDatasource(this._dio);

  @override
  Future<ResumenSalud> getResumenSalud(Persona persona) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerResumenSaludPath,
        data: {'personaID': persona.id},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) return const ResumenSalud();

      return ResumenSaludMapper.fromModel(ResumenSaludModel.fromJson(data));
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
