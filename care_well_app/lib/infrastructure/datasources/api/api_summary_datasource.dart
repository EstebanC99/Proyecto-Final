import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/exceptions/exceptions.dart';
import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:dio/dio.dart';

/// Implementación contra la API del [SummaryDatasource] (US 9.16).
///
/// La generación del resumen la resuelve el backend invocando al modelo de IA
/// en el momento (sin caché), por lo que puede demorar bastante más que el
/// resto de los endpoints: se usa un `receiveTimeout` propio y más generoso.
class ApiSummaryDatasource implements SummaryDatasource {
  final Dio _dio;

  ApiSummaryDatasource(this._dio);

  @override
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    // Se ignora a propósito: el backend no cachea el resumen en el MVP.
    bool forzarActualizacion = false,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerResumenInteligentePath,
        data: {'personaCuidadaID': personaId},
        options: Options(
          receiveTimeout: ApiConfig.receiveTimeoutResumenInteligente,
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) throw const ServidorException();

      return ResumenInteligenteMapper.fromModel(
        ResumenInteligenteModel.fromJson(data),
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
