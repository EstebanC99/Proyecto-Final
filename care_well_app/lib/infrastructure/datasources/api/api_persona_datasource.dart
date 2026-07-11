import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import '../../http/api_config.dart';
import '../../http/api_exception_mapper.dart';

/// Implementación de [PersonaDatasource] contra la API REST de CareWell.
///
/// Los métodos aún sin endpoint disponible quedan con [UnimplementedError].
class ApiPersonaDatasource implements PersonaDatasource {
  final Dio _dio;

  ApiPersonaDatasource(this._dio);

  @override
  Future<Uint8List?> getImagen(int id) async {
    try {
      final response = await _dio.get<List<int>>(
        ApiConfig.imagenPersonaPath(id),
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data == null) return null;
      return Uint8List.fromList(data);
    } on DioException catch (e) {
      // La persona no tiene imagen cargada → se muestra el fallback de iniciales.
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Persona> actualizar(Persona persona) async {
    try {
      await _dio.post(
        ApiConfig.modificarPerfil,
        data: {
          'id': persona.id,
          'nombre': persona.nombre,
          'apellido': persona.apellido,
          'documento': persona.documento,
          'fechaNacimiento': persona.fechaNacimiento.toIso8601String(),
          'telefono': persona.telefono ?? '',
          // Imagen de perfil en base64 estándar (sin prefijo data-URI).
          // Se omite si es null; el email es concern de credenciales.
          'imagen': ?persona.imagen,
        },
      );
      return persona;
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  // ── Métodos pendientes de endpoint ────────────────────────────────────────

  @override
  Future<Persona> getById(int id) =>
      throw UnimplementedError('TODO: endpoint pendiente en el backend.');

  @override
  Future<List<Persona>> getDependientesByUsuario(int usuarioId) =>
      throw UnimplementedError('TODO: endpoint pendiente en el backend.');

  @override
  Future<Persona> crear(Persona persona) =>
      throw UnimplementedError('TODO: endpoint pendiente en el backend.');

  @override
  Future<void> eliminar(int id) =>
      throw UnimplementedError('TODO: endpoint pendiente en el backend.');
}
