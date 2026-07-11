import 'dart:typed_data';

import 'package:care_well_app/infrastructure/datasources/api/api_persona_datasource.dart';
import 'package:care_well_app/infrastructure/http/api_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter de Dio que captura la última [RequestOptions] y responde con un
/// cuerpo binario y un status configurables, sin abrir conexiones de red.
class _BytesAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  final List<int> responseBytes;
  final int statusCode;

  _BytesAdapter({this.responseBytes = const [], this.statusCode = 200});

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromBytes(
      responseBytes,
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['image/jpeg'],
      },
    );
  }
}

(Dio, _BytesAdapter) _buildDio({
  List<int> responseBytes = const [],
  int statusCode = 200,
}) {
  final adapter = _BytesAdapter(
    responseBytes: responseBytes,
    statusCode: statusCode,
  );
  final dio = Dio()..httpClientAdapter = adapter;
  return (dio, adapter);
}

void main() {
  group('ApiPersonaDatasource.getImagen', () {
    test('usa el path correcto y devuelve los bytes ante un 200', () async {
      final bytes = [1, 2, 3, 4, 5];
      final (dio, adapter) = _buildDio(responseBytes: bytes, statusCode: 200);
      final datasource = ApiPersonaDatasource(dio);

      final result = await datasource.getImagen(42);

      expect(adapter.lastRequest?.method, 'GET');
      expect(adapter.lastRequest?.path, ApiConfig.imagenPersonaPath(42));
      expect(result, isA<Uint8List>());
      expect(result, equals(Uint8List.fromList(bytes)));
    });

    test('devuelve null cuando el backend responde 404', () async {
      final (dio, _) = _buildDio(statusCode: 404);
      final datasource = ApiPersonaDatasource(dio);

      final result = await datasource.getImagen(7);

      expect(result, isNull);
    });

    test('propaga el error ante un status distinto de 404', () async {
      final (dio, _) = _buildDio(statusCode: 500);
      final datasource = ApiPersonaDatasource(dio);

      expect(datasource.getImagen(7), throwsA(isA<DioException>()));
    });
  });
}
