import 'package:care_well_app/infrastructure/models/models.dart';

class AsignacionCuidadoModel {
  final int id;
  final PersonaModel persona;
  final PersonaModel colaborador;
  final RolCuidadoModel rol;
  final EstadoAsignacionCuidadoModel estado;
  final String fechaAlta;
  final String? fechaEliminacion;
  final List<PermisoCuidadoModel> permisos;

  const AsignacionCuidadoModel({
    required this.id,
    required this.persona,
    required this.colaborador,
    required this.rol,
    required this.estado,
    required this.fechaAlta,
    this.fechaEliminacion,
    this.permisos = const [],
  });

  factory AsignacionCuidadoModel.fromJson(Map<String, dynamic> json) {
    final permisosList = (json['permisos'] as List<dynamic>?) ?? [];

    return AsignacionCuidadoModel(
      id: json['id'] as int,
      persona: PersonaModel.fromJson(json['persona']),
      colaborador: PersonaModel.fromJson(json['colaborador']),
      rol: RolCuidadoModel.fromJson(json['rol']),
      estado: EstadoAsignacionCuidadoModel.fromJson(json['estado']),
      fechaAlta: json['fechaAlta'],
      fechaEliminacion: json['fechaEliminacion'] as String?,
      permisos: permisosList
          .map((e) => PermisoCuidadoModel.fromJson(e))
          .toList(),
    );
  }
}
