import 'package:care_well_app/domain/datasources/asignacion_cuidado_datasource.dart';
import 'package:care_well_app/domain/entities/care_team/asignacion_cuidado.dart';
import 'package:care_well_app/domain/entities/shared/persona.dart';
import 'package:care_well_app/infrastructure/http/api_config.dart';
import 'package:care_well_app/infrastructure/http/api_exception_mapper.dart';
import 'package:care_well_app/infrastructure/mappers/care_team/asignacion_cuidado_mapper.dart';
import 'package:care_well_app/infrastructure/models/care_team/asignacion_cuidado_model.dart';
import 'package:dio/dio.dart';

class ApiAsignacionCuidadoDatasource implements AsignacionCuidadoDatasource {
  final Dio _dio;

  ApiAsignacionCuidadoDatasource(this._dio);

  List<AsignacionCuidadoModel> _jsonToAsignacionesCuidadoModel(
    List<dynamic> json,
  ) {
    return json
        .map((e) => AsignacionCuidadoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado() async {
    try {
      final response = await _dio.post(ApiConfig.obtenerMisAsignacionesPath);

      final asignacionesModel = _jsonToAsignacionesCuidadoModel(
        response.data as List<dynamic>,
      );

      return asignacionesModel
          .map((e) => AsignacionCuidadoMapper.fromModel(e))
          .toList();
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesPorPersona(
    int personaCuidadaId,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerAsignacionesPorPersona,
        data: {'personaCuidadaId': personaCuidadaId},
      );

      final asignacionesModel = _jsonToAsignacionesCuidadoModel(
        response.data as List<dynamic>,
      );

      return asignacionesModel
          .map((e) => AsignacionCuidadoMapper.fromModel(e))
          .toList();
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> crearPersonaCargo({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    String? email,
    String? telefono,
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
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<Persona> modificarPersonaCargo(
    int asignacionId,
    Persona persona,
  ) async {
    try {
      await _dio.post(
        ApiConfig.modificarPersonaCargoPath,
        data: {
          'asignacionCuidadoId': asignacionId,
          'nombre': persona.nombre,
          'apellido': persona.apellido,
          'documento': persona.documento,
          'fechaNacimiento': persona.fechaNacimiento.toIso8601String(),
          'email': persona.email ?? '',
          'telefono': persona.telefono ?? '',
        },
      );
      return persona;
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> eliminarAsignacion(int asignacionId) async {
    try {
      await _dio.post(ApiConfig.eliminarAsignacionPath, data: asignacionId);
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> activarAsignacion(int asignacionId) async {
    try {
      await _dio.post(ApiConfig.activarAsignacionPath, data: asignacionId);
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> reactivarAsignacion(int asignacionId) async {
    try {
      await _dio.post(ApiConfig.reactivarAsignacionPath, data: asignacionId);
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }

  @override
  Future<void> asignarPersonaEquipoCuidado({
    required int personaCuidadaId,
    required String colaboradorEmail,
    required int rolCuidadoId,
    required List<int> permisosCuidadoIds,
  }) async {
    try {
      await _dio.post(
        ApiConfig.asignar,
        data: {
          'personaCuidadaId': personaCuidadaId,
          'colaboradorEmail': colaboradorEmail,
          'rolCuidadoId': rolCuidadoId,
          'permisosIds': permisosCuidadoIds,
        },
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.map(e);
    }
  }
}
