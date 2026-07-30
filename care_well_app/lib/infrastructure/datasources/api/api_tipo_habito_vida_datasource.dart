import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:dio/dio.dart';

class ApiTipoHabitoVidaDatasource implements TipoHabitoVidaDatasource {
  final Dio _dio;

  ApiTipoHabitoVidaDatasource(this._dio);

  @override
  Future<List<TipoHabitoVida>> obtenerTiposHabitosVida() async {
    try {
      final response = await _dio.post(ApiConfig.obtenerTiposHabitosVidaPath);

      return (response.data as List<dynamic>)
          .map(
            (e) => TipoHabitoMapper.fromModel(
              EntidadBasicaModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}