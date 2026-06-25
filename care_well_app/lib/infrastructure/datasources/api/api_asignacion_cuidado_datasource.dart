import 'package:dio/dio.dart';

import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import '../../http/http_configs.dart';
import '../../mappers/mappers.dart';
import '../../models/models.dart';

class ApiAsignacionCuidadoDatasource implements AsignacionCuidadoDatasource {
  final Dio _dio;

  ApiAsignacionCuidadoDatasource(this._dio);

  @override
  Future<void> crearPersonaCargo({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    String? email,
    String? telefono,
    List<int> permisosCuidadoIds = const [],
  }) async {
    try {
      await _dio.post(
        ApiConfig.crearPersonaCargoPath,
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'documento': documento,
          'fechaNacimiento': fechaNacimiento.toIso8601String(),
          'email': email ?? '',
          'telefono': telefono ?? '',
          'permisosCuidadoIds': permisosCuidadoIds,
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado() async {
    try {
      final response = await _dio.get(ApiConfig.obtenerMisAsignacionesPath);
      final list = response.data as List<dynamic>;
      return list
          .map(
            (e) => AsignacionCuidadoApiMapper.fromModel(
              AsignacionCuidadoApiModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
