import 'package:care_well_app/domain/exceptions/exceptions.dart';
import 'package:dio/dio.dart';

class ApiExceptionMapper {
  static Exception map(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return const SinConexionException();
    }

    final statusCode = err.response?.statusCode;
    final mensaje = _extractMensaje(err);

    return switch (statusCode) {
      400 => ValidacionException(mensaje ?? 'Datos inválidos.'),
      401 => CredencialesInvalidasException(
        mensaje ?? 'Credenciales inválidas.',
      ),
      403 => EmailNoVerificadoException(
        mensaje ?? 'Tu email aún no fue verificado.',
      ),
      404 => RecursoNoEncontradoException(
        mensaje ?? 'El recurso solicitado no fue encontrado.',
      ),
      409 => const CuentaExistenteException(),
      _ => const ServidorException(),
    };
  }

  static String? _extractMensaje(DioException err) {
    try {
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        return data['mensaje'] as String?;
      }
    } catch (_) {}
    return null;
  }
}
