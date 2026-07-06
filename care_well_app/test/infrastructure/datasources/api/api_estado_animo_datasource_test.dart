import 'dart:convert';
import 'dart:typed_data';

import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/datasources/api/api_estado_animo_datasource.dart';
import 'package:care_well_app/infrastructure/http/api_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter de Dio que responde con un cuerpo y status predefinidos, sin abrir
/// ninguna conexión de red. Permite simular respuestas "sin contenido".
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

final _persona = Persona(
  id: 7,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

void main() {
  group('ApiEstadoAnimoDatasource.obtenerAnimoHoy', () {
    test('usa el path correcto y envía el personaID', () async {
      final (dio, adapter) = _buildDio();
      final datasource = ApiEstadoAnimoDatasource(dio);

      await datasource.obtenerAnimoHoy(_persona);

      expect(adapter.lastRequest!.path, ApiConfig.obtenerAnimoHoyPath);
      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(body['personaID'], 7);
    });

    test(
      'body JSON null (HTTP 200) se interpreta como "sin ánimo" → null',
      () async {
        final (dio, _) = _buildDio(responseBody: 'null');
        final datasource = ApiEstadoAnimoDatasource(dio);

        final resultado = await datasource.obtenerAnimoHoy(_persona);

        expect(resultado, isNull);
      },
    );

    test('body vacío (HTTP 204) no lanza y devuelve null', () async {
      final (dio, _) = _buildDio(responseBody: '', statusCode: 204);
      final datasource = ApiEstadoAnimoDatasource(dio);

      final resultado = await datasource.obtenerAnimoHoy(_persona);

      expect(resultado, isNull);
    });

    test('body vacío (HTTP 200) no lanza y devuelve null', () async {
      final (dio, _) = _buildDio(responseBody: '', statusCode: 200);
      final datasource = ApiEstadoAnimoDatasource(dio);

      final resultado = await datasource.obtenerAnimoHoy(_persona);

      expect(resultado, isNull);
    });

    test('body con objeto se mapea a EstadoDeAnimo de la persona', () async {
      final responseBody = jsonEncode({
        'id': 55,
        'estadoAnimo': {'id': 4, 'descripcion': 'Bien'},
        'fechaHora': '2026-07-06T10:00:00.000',
        'observaciones': 'Tranquila',
      });
      final (dio, _) = _buildDio(responseBody: responseBody);
      final datasource = ApiEstadoAnimoDatasource(dio);

      final resultado = await datasource.obtenerAnimoHoy(_persona);

      expect(resultado, isNotNull);
      expect(resultado!.id, 55);
      expect(resultado.estado.id, 4);
      expect(resultado.observaciones, 'Tranquila');
      expect(resultado.persona.id, _persona.id);
    });
  });
}
