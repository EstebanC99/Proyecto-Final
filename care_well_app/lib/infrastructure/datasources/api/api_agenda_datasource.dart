import 'package:care_well_app/domain/datasources/agenda_datasource.dart';
import 'package:care_well_app/domain/entities/agenda/ocurrencia_evento_agenda.dart';
import 'package:care_well_app/infrastructure/http/api_config.dart';
import 'package:care_well_app/infrastructure/http/api_exception_mapper.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:dio/dio.dart';

class ApiAgendaDatasource implements AgendaDatasource {
  final Dio _dio;

  ApiAgendaDatasource(this._dio);

  @override
  Future<List<OcurrenciaEventoAgenda>> obtenerOcurrencias({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerOcurrenciasAgendaPath,
        data: {
          'personaID': personaId,
          'fechaDesde': desde.toIso8601String(),
          'fechaHasta': hasta.toIso8601String(),
        },
      );

      return (response.data as List<dynamic>)
          .map(
            (e) => OcurrenciaEventoAgendaMapper.fromModel(
              OcurrenciaEventoAgendaModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> crearEvento({
    required int personaId,
    required String titulo,
    String? descripcion,
    required int tipoEventoId,
    required DateTime fechaHoraInicio,
    required int duracionMinutos,
    required bool generarEventoSalud,
    int? minutosAnticipacionRecordatorio,
    int? frecuenciaRecurrenciaId,
    int? intervaloRecurrencia,
    DateTime? fechaFinRecurrencia,
  }) async {
    try {
      await _dio.post(
        ApiConfig.crearEventoAgendaPath,
        data: {
          'personaID': personaId,
          'titulo': titulo,
          'descripcion': ?descripcion,
          'tipoEventoID': tipoEventoId,
          'fechaHoraInicio': fechaHoraInicio.toIso8601String(),
          'duracionMinutos': duracionMinutos,
          'generarEventoSalud': generarEventoSalud,
          'minutosAnticipacionRecordatorio': ?minutosAnticipacionRecordatorio,
          'frecuenciaRecurrenciaID': ?frecuenciaRecurrenciaId,
          'intervaloRecurrencia': ?intervaloRecurrencia,
          'fechaFinRecurrencia': ?fechaFinRecurrencia?.toIso8601String(),
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> modificarEvento({
    required int eventoAgendaId,
    required String titulo,
    String? descripcion,
    required int tipoEventoId,
    required DateTime fechaHoraInicio,
    required int duracionMinutos,
    required bool generarEventoSalud,
    int? minutosAnticipacionRecordatorio,
  }) async {
    try {
      await _dio.post(
        ApiConfig.modificarEventoAgendaPath,
        data: {
          'eventoAgendaID': eventoAgendaId,
          'titulo': titulo,
          'descripcion': ?descripcion,
          'tipoEventoID': tipoEventoId,
          'fechaHoraInicio': fechaHoraInicio.toIso8601String(),
          'duracionMinutos': duracionMinutos,
          'generarEventoSalud': generarEventoSalud,
          'minutosAnticipacionRecordatorio': ?minutosAnticipacionRecordatorio,
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> eliminarEvento(int eventoAgendaId) async {
    try {
      await _dio.post(ApiConfig.eliminarEventoAgendaPath, data: eventoAgendaId);
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> cancelarOcurrencia({
    required int eventoAgendaId,
    required DateTime fechaOcurrencia,
  }) async {
    try {
      await _dio.post(
        ApiConfig.cancelarOcurrenciaAgendaPath,
        data: {
          'eventoAgendaID': eventoAgendaId,
          'fechaOcurrencia': fechaOcurrencia.toIso8601String(),
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> cancelarSerieDesde({
    required int eventoAgendaId,
    required DateTime fechaOcurrencia,
  }) async {
    try {
      await _dio.post(
        ApiConfig.cancelarSerieAgendaPath,
        data: {
          'eventoAgendaID': eventoAgendaId,
          'fechaOcurrencia': fechaOcurrencia.toIso8601String(),
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
