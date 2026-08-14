import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/exceptions/exceptions.dart';
import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:dio/dio.dart';

/// Implementación contra la API del [SummaryDatasource] (US 9.16).
///
/// El backend persiste un resumen por persona cuidada y lo reutiliza mientras
/// sea del mismo día y tenga menos de 3 horas, así que muchas consultas
/// resuelven en milisegundos. Pero el primer pedido del día —y cualquiera con
/// [obtenerResumen] forzado— sí invoca al modelo de IA y puede demorar bastante
/// más que el resto de los endpoints: por eso se usa un `receiveTimeout` propio
/// y más generoso.
class ApiSummaryDatasource implements SummaryDatasource {
  final Dio _dio;

  ApiSummaryDatasource(this._dio);

  @override
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    bool forzarActualizacion = false,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerResumenInteligentePath,
        data: {
          'personaCuidadaID': personaId,
          // OJO: la clave que espera el backend es 'actualizar'
          // (GenerarResumenDiarioQuery.Actualizar). Con cualquier otro nombre,
          // el binding la descarta en silencio y nunca se regenera.
          'actualizar': forzarActualizacion,
        },
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
