import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:dio/dio.dart';

class ApiFichaSaludDatasource implements FichaSaludDatasource {
  final Dio _dio;

  ApiFichaSaludDatasource(this._dio);

  @override
  Future<FichaSalud?> getFichaSalud(Persona persona) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerFichaSaludPath,
        data: {'personaID': persona.id},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) return null;

      return FichaSaludMapper.fromModel(
        FichaSaludModel.fromJson(response.data),
        persona,
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> guardarFichaSalud(FichaSalud ficha) async {
    try {
      final path = ficha.id == 0
          ? ApiConfig.crearFichaSaludPath
          : ApiConfig.modificarFichaSaludPath;

      await _dio.post(path, data: FichaSaludMapper.toModel(ficha).toJson());
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
