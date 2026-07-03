import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/agenda/tipo_evento.dart';
import 'package:care_well_app/infrastructure/http/api_config.dart';
import 'package:care_well_app/infrastructure/http/api_exception_mapper.dart';
import 'package:care_well_app/infrastructure/mappers/shared/tipo_evento_mapper.dart';
import 'package:care_well_app/infrastructure/models/shared/tipo_evento_model.dart';
import 'package:dio/dio.dart';

class ApiTipoEventoDatasource implements TipoEventoDatasource {
  final Dio _dio;

  ApiTipoEventoDatasource(this._dio);

  @override
  Future<List<TipoEvento>> obtenerTiposEvento() async {
    try {
      final response = await _dio.post(ApiConfig.obtenerTiposEventoPath);

      return (response.data as List<dynamic>)
          .map(
            (e) => TipoEventoMapper.fromModel(
              TipoEventoModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
