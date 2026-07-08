import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:dio/dio.dart';

class ApiAlertaBienestarDatasource implements AlertaBienestarDatasource {
  final Dio _dio;

  ApiAlertaBienestarDatasource(this._dio);

  @override
  Future<List<AlertaBienestar>> getAlertasBienestar(Persona persona) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerAlertasBienestarPath,
        data: {'personaID': persona.id},
      );

      final data = response.data;
      if (data is! List) return const [];

      return (response.data as List<dynamic>)
          .map(
            (e) => AlertaBienestarMapper.fromModel(
              AlertaBienestarModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
