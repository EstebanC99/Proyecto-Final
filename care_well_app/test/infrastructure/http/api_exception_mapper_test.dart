import 'package:care_well_app/domain/exceptions/exceptions.dart';
import 'package:care_well_app/infrastructure/http/api_exception_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dioError({required int statusCode, String? mensaje}) {
  final requestOptions = RequestOptions(path: '/test');
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: mensaje == null ? null : {'mensaje': mensaje},
    ),
  );
}

void main() {
  group('ApiExceptionMapper', () {
    test(
      '403 mapea a EmailNoVerificadoException con el mensaje del backend',
      () {
        final result = ApiExceptionMapper.map(
          _dioError(statusCode: 403, mensaje: 'Verificá tu email primero.'),
        );

        expect(result, isA<EmailNoVerificadoException>());
        expect(
          (result as EmailNoVerificadoException).mensaje,
          'Verificá tu email primero.',
        );
      },
    );

    test('403 sin mensaje usa un texto por defecto', () {
      final result = ApiExceptionMapper.map(_dioError(statusCode: 403));

      expect(result, isA<EmailNoVerificadoException>());
      expect(
        (result as EmailNoVerificadoException).mensaje,
        'Tu email aún no fue verificado.',
      );
    });

    test('401 sigue mapeando a CredencialesInvalidasException', () {
      final result = ApiExceptionMapper.map(_dioError(statusCode: 401));

      expect(result, isA<CredencialesInvalidasException>());
    });

    test('400 mapea a ValidacionException con el mensaje del backend', () {
      final result = ApiExceptionMapper.map(
        _dioError(statusCode: 400, mensaje: 'Código inválido o expirado.'),
      );

      expect(result, isA<ValidacionException>());
      expect(
        (result as ValidacionException).mensaje,
        'Código inválido o expirado.',
      );
    });

    test(
      '503 mapea a ServicioNoDisponibleException con el mensaje del backend',
      () {
        final result = ApiExceptionMapper.map(
          _dioError(
            statusCode: 503,
            mensaje:
                'El servicio de validación de identidad no está disponible '
                'en este momento. Reintentá en unos minutos.',
          ),
        );

        expect(result, isA<ServicioNoDisponibleException>());
        expect(
          (result as ServicioNoDisponibleException).mensaje,
          'El servicio de validación de identidad no está disponible '
          'en este momento. Reintentá en unos minutos.',
        );
      },
    );

    test('503 sin mensaje usa un texto por defecto', () {
      final result = ApiExceptionMapper.map(_dioError(statusCode: 503));

      expect(result, isA<ServicioNoDisponibleException>());
      expect(
        (result as ServicioNoDisponibleException).mensaje,
        'El servicio no está disponible en este momento. '
        'Reintentá en unos minutos.',
      );
    });
  });
}
