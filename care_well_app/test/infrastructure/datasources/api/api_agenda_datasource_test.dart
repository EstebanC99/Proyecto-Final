import 'dart:convert';
import 'dart:typed_data';

import 'package:care_well_app/infrastructure/datasources/api/api_agenda_datasource.dart';
import 'package:care_well_app/infrastructure/http/api_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter de Dio que captura la última [RequestOptions] enviada y responde
/// con un cuerpo JSON predefinido, sin abrir ninguna conexión de red.
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  final String responseBody;

  _CapturingAdapter({this.responseBody = 'null'});

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
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

/// Construye un [Dio] con el adapter de captura instalado.
(Dio, _CapturingAdapter) _buildDio({String responseBody = 'null'}) {
  final adapter = _CapturingAdapter(responseBody: responseBody);
  final dio = Dio()..httpClientAdapter = adapter;
  return (dio, adapter);
}

void main() {
  group('ApiAgendaDatasource', () {
    group('obtenerOcurrencias', () {
      test(
        'usa el path correcto, envía el body en ISO y parsea la respuesta',
        () async {
          final responseBody = jsonEncode([
            {
              'eventoAgendaID': 501,
              'personaID': 12,
              'titulo': 'Control cardiológico',
              'descripcion': 'Llevar estudios',
              'tipo': {
                'id': 1,
                'descripcion': 'Cita Médica',
                'agendable': true,
              },
              'fechaHoraInicio': '2026-07-15T09:30:00.000',
              'fechaHoraFin': '2026-07-15T10:00:00.000',
              'esRecurrente': false,
              'generarEventoSalud': true,
              'minutosAnticipacionRecordatorio': 30,
            },
          ]);
          final (dio, adapter) = _buildDio(responseBody: responseBody);
          final datasource = ApiAgendaDatasource(dio);

          final desde = DateTime(2026, 7, 1);
          final hasta = DateTime(2026, 8, 1);

          final ocurrencias = await datasource.obtenerOcurrencias(
            personaId: 12,
            desde: desde,
            hasta: hasta,
          );

          // Path.
          expect(
            adapter.lastRequest!.path,
            ApiConfig.obtenerOcurrenciasAgendaPath,
          );

          // Body enviado.
          final body = adapter.lastRequest!.data as Map<String, dynamic>;
          expect(body['personaID'], 12);
          expect(body['fechaDesde'], desde.toIso8601String());
          expect(body['fechaHasta'], hasta.toIso8601String());

          // Respuesta parseada.
          expect(ocurrencias, hasLength(1));
          expect(ocurrencias.first.eventoAgendaId, 501);
          expect(ocurrencias.first.personaId, 12);
          expect(
            ocurrencias.first.fechaHoraInicio,
            DateTime(2026, 7, 15, 9, 30),
          );
          expect(ocurrencias.first.minutosAnticipacionRecordatorio, 30);
        },
      );
    });

    group('crearEvento', () {
      test('usa el path correcto y envía las claves del command', () async {
        final (dio, adapter) = _buildDio();
        final datasource = ApiAgendaDatasource(dio);

        final inicio = DateTime(2026, 7, 20, 8, 0);

        await datasource.crearEvento(
          personaId: 12,
          titulo: 'Vacuna',
          descripcion: 'Antigripal',
          tipoEventoId: 1,
          fechaHoraInicio: inicio,
          duracionMinutos: 30,
          generarEventoSalud: true,
          minutosAnticipacionRecordatorio: 60,
        );

        expect(adapter.lastRequest!.path, ApiConfig.crearEventoAgendaPath);

        final body = adapter.lastRequest!.data as Map<String, dynamic>;
        expect(body['personaID'], 12);
        expect(body['titulo'], 'Vacuna');
        expect(body['descripcion'], 'Antigripal');
        expect(body['tipoEventoID'], 1);
        expect(body['fechaHoraInicio'], inicio.toIso8601String());
        expect(body['duracionMinutos'], 30);
        expect(body['generarEventoSalud'], true);
        expect(body['minutosAnticipacionRecordatorio'], 60);
      });

      test('los opcionales nulos se omiten del body', () async {
        final (dio, adapter) = _buildDio();
        final datasource = ApiAgendaDatasource(dio);

        await datasource.crearEvento(
          personaId: 12,
          titulo: 'Evento sin extras',
          tipoEventoId: 4,
          fechaHoraInicio: DateTime(2026, 7, 21, 9, 0),
          duracionMinutos: 15,
          generarEventoSalud: false,
        );

        final body = adapter.lastRequest!.data as Map<String, dynamic>;
        expect(body.containsKey('descripcion'), isFalse);
        expect(body.containsKey('minutosAnticipacionRecordatorio'), isFalse);
        expect(body.containsKey('frecuenciaRecurrenciaID'), isFalse);
        expect(body.containsKey('intervaloRecurrencia'), isFalse);
        expect(body.containsKey('fechaFinRecurrencia'), isFalse);
        // Los requeridos siguen presentes.
        expect(body['personaID'], 12);
        expect(body['tipoEventoID'], 4);
      });

      test('las claves de recurrencia se incluyen cuando se proveen', () async {
        final (dio, adapter) = _buildDio();
        final datasource = ApiAgendaDatasource(dio);

        final finRecurrencia = DateTime(2026, 12, 31);

        await datasource.crearEvento(
          personaId: 12,
          titulo: 'Medicación diaria',
          tipoEventoId: 2,
          fechaHoraInicio: DateTime(2026, 7, 20, 8, 0),
          duracionMinutos: 5,
          generarEventoSalud: false,
          frecuenciaRecurrenciaId: 1,
          intervaloRecurrencia: 1,
          fechaFinRecurrencia: finRecurrencia,
        );

        final body = adapter.lastRequest!.data as Map<String, dynamic>;
        expect(body['frecuenciaRecurrenciaID'], 1);
        expect(body['intervaloRecurrencia'], 1);
        expect(body['fechaFinRecurrencia'], finRecurrencia.toIso8601String());
      });
    });

    group('eliminarEvento', () {
      test('envía el path correcto y un int plano como body', () async {
        final (dio, adapter) = _buildDio();
        final datasource = ApiAgendaDatasource(dio);

        await datasource.eliminarEvento(42);

        expect(adapter.lastRequest!.path, ApiConfig.eliminarEventoAgendaPath);
        expect(adapter.lastRequest!.data, 42);
        expect(adapter.lastRequest!.data, isA<int>());
      });
    });

    group('cancelarOcurrencia', () {
      test(
        'envía el path correcto y el body { eventoAgendaID, fechaOcurrencia }',
        () async {
          final (dio, adapter) = _buildDio();
          final datasource = ApiAgendaDatasource(dio);

          final fecha = DateTime(2026, 7, 15, 9, 30);

          await datasource.cancelarOcurrencia(
            eventoAgendaId: 501,
            fechaOcurrencia: fecha,
          );

          expect(
            adapter.lastRequest!.path,
            ApiConfig.cancelarOcurrenciaAgendaPath,
          );

          final body = adapter.lastRequest!.data as Map<String, dynamic>;
          expect(body.keys, containsAll(['eventoAgendaID', 'fechaOcurrencia']));
          expect(body['eventoAgendaID'], 501);
          expect(body['fechaOcurrencia'], fecha.toIso8601String());
        },
      );
    });

    group('cancelarSerieDesde', () {
      test(
        'envía el path correcto y el body { eventoAgendaID, fechaOcurrencia }',
        () async {
          final (dio, adapter) = _buildDio();
          final datasource = ApiAgendaDatasource(dio);

          final fecha = DateTime(2026, 7, 15, 9, 30);

          await datasource.cancelarSerieDesde(
            eventoAgendaId: 501,
            fechaOcurrencia: fecha,
          );

          expect(adapter.lastRequest!.path, ApiConfig.cancelarSerieAgendaPath);

          final body = adapter.lastRequest!.data as Map<String, dynamic>;
          expect(body.keys, containsAll(['eventoAgendaID', 'fechaOcurrencia']));
          expect(body['eventoAgendaID'], 501);
          expect(body['fechaOcurrencia'], fecha.toIso8601String());
        },
      );
    });
  });
}
