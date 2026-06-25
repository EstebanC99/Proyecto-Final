import 'package:dio/dio.dart';

import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';

/// Implementación de [PersonaDatasource] contra la API REST de CareWell.
///
/// Todos los métodos quedan con [UnimplementedError] hasta que los endpoints
/// correspondientes estén disponibles en el backend.
// ignore_for_file: unused_field
class ApiPersonaDatasource implements PersonaDatasource {
  final Dio _dio;

  ApiPersonaDatasource(this._dio);

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
  Future<Persona> actualizar(Persona persona) =>
      throw UnimplementedError('TODO: endpoint pendiente en el backend.');

  @override
  Future<void> eliminar(int id) =>
      throw UnimplementedError('TODO: endpoint pendiente en el backend.');
}
