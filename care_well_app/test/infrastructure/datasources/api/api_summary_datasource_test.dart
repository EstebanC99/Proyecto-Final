import 'dart:convert';
import 'dart:typed_data';

import 'package:care_well_app/domain/exceptions/exceptions.dart';
import 'package:care_well_app/infrastructure/datasources/api/api_summary_datasource.dart';
import 'package:care_well_app/infrastructure/http/api_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter de Dio que responde con un cuerpo y status predefinidos, sin abrir
/// ninguna conexión de red.
class _StubAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  final String responseBody;
  final int statusCode;

  _StubAdapter({this.responseBody = 'null', this.statusCode = 200});

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      responseBody,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

(Dio, _StubAdapter) _buildDio({
  String responseBody = 'null',
  int statusCode = 200,
}) {
  final adapter = _StubAdapter(
    responseBody: responseBody,
    statusCode: statusCode,
  );
  final dio = Dio()..httpClientAdapter = adapter;
  return (dio, adapter);
}

const _bodyConDatos = {
  'resumenAcotado': 'Hoy Alicia tuvo una jornada tranquila.',
  'estadoAnimo': 'Tranquila',
  'resumenHabitos': 'Cumplió con casi toda la rutina.',
  'habitos': [
    {'descripcion': 'Caminata matutina', 'completado': true},
    {'descripcion': 'Cena liviana', 'completado': false},
  ],
  'eventosSalud': [
    {
      'descripcion': 'Control de presión',
      'hora': '08:45:00',
      'actividadHabitoAsociado': 'Durante el desayuno',
    },
  ],
  'recomendaciones': ['Registrar la cena cuando ocurra.'],
  'recordatoriosHoy': ['Turno con la kinesióloga a las 18:00'],
  'recordatoriosManana': ['Análisis de sangre en ayunas'],
  'habitosManana': [
    {'descripcion': 'Caminata matutina', 'completado': false},
  ],
  'generadoEn': '2026-07-31T14:32:10',
  'tieneDatos': true,
};

void main() {
  group('ApiSummaryDatasource.obtenerResumen', () {
    test('usa el path correcto y envía el personaCuidadaID', () async {
      final (dio, adapter) = _buildDio(responseBody: jsonEncode(_bodyConDatos));
      final datasource = ApiSummaryDatasource(dio);

      await datasource.obtenerResumen(personaId: 7);

      expect(
        adapter.lastRequest!.path,
        ApiConfig.obtenerResumenInteligentePath,
      );
      expect(adapter.lastRequest!.method, 'POST');
      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(body['personaCuidadaID'], 7);
    });

    test('aplica el receiveTimeout propio del resumen inteligente', () async {
      final (dio, adapter) = _buildDio(responseBody: jsonEncode(_bodyConDatos));
      final datasource = ApiSummaryDatasource(dio);

      await datasource.obtenerResumen(personaId: 7);

      expect(
        adapter.lastRequest!.receiveTimeout,
        ApiConfig.receiveTimeoutResumenInteligente,
      );
    });

    test('mapea la respuesta a ResumenInteligente', () async {
      final (dio, _) = _buildDio(responseBody: jsonEncode(_bodyConDatos));
      final datasource = ApiSummaryDatasource(dio);

      final resultado = await datasource.obtenerResumen(personaId: 7);

      expect(
        resultado.resumenAcotado,
        'Hoy Alicia tuvo una jornada tranquila.',
      );
      expect(resultado.estadoAnimo, 'Tranquila');
      expect(resultado.habitos, hasLength(2));
      expect(resultado.habitosCompletados, 1);
      expect(resultado.eventosSalud.single.hora, '08:45');
      expect(resultado.recomendaciones, hasLength(1));
      expect(resultado.recordatoriosHoy, hasLength(1));
      expect(resultado.recordatoriosManana, hasLength(1));
      expect(resultado.habitosManana, hasLength(1));
      expect(resultado.tieneDatos, isTrue);
      expect(resultado.generadoEn, DateTime(2026, 7, 31, 14, 32, 10));
    });

    test('mapea el caso sin datos (listas vacías, tieneDatos false)', () async {
      final responseBody = jsonEncode({
        'resumenAcotado': null,
        'estadoAnimo': 'Sin registros',
        'resumenHabitos': 'Sin registros',
        'habitos': [],
        'eventosSalud': [],
        'recomendaciones': [],
        'recordatoriosHoy': [],
        'recordatoriosManana': [],
        'habitosManana': [],
        'generadoEn': '2026-07-31T14:32:10',
        'tieneDatos': false,
      });
      final (dio, _) = _buildDio(responseBody: responseBody);
      final datasource = ApiSummaryDatasource(dio);

      final resultado = await datasource.obtenerResumen(personaId: 7);

      expect(resultado.resumenAcotado, isNull);
      expect(resultado.estadoAnimo, isNull);
      expect(resultado.habitos, isEmpty);
      expect(resultado.tieneDatos, isFalse);
    });

    test('respuesta con forma inesperada lanza ServidorException', () async {
      final (dio, _) = _buildDio(responseBody: 'null');
      final datasource = ApiSummaryDatasource(dio);

      expect(
        () => datasource.obtenerResumen(personaId: 7),
        throwsA(isA<ServidorException>()),
      );
    });

    test('un 503 se traduce a ServicioNoDisponibleException', () async {
      final responseBody = jsonEncode({'mensaje': 'Ollama no responde.'});
      final (dio, _) = _buildDio(responseBody: responseBody, statusCode: 503);
      final datasource = ApiSummaryDatasource(dio);

      expect(
        () => datasource.obtenerResumen(personaId: 7),
        throwsA(isA<ServicioNoDisponibleException>()),
      );
    });
  });
}
