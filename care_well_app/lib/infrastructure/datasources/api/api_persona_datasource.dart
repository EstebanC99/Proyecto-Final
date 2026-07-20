import 'dart:typed_data';

import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:dio/dio.dart';

import '../../http/api_config.dart';
import '../../http/api_exception_mapper.dart';

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
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Persona> actualizar(Persona persona) async {
    try {
      await _dio.post(
        ApiConfig.modificarPerfil,
        data: PersonaMapper.toModel(persona).toJson(),
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
