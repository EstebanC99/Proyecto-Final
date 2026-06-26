import 'package:care_well_app/domain/entities/care_team/estado_asignacion_cuidado.dart';

import '../base_entity.dart';
import '../shared/persona.dart';
import 'permiso_cuidado.dart';
import 'rol_cuidado.dart';

class AsignacionCuidado extends BaseEntity {
  final Persona personaCuidada;
  final Persona colaborador;
  final RolCuidado rol;
  final EstadoAsignacionCuidado estado;
  final DateTime fechaAlta;
  final List<PermisoCuidado> permisos;

  const AsignacionCuidado({
    required super.id,
    required this.personaCuidada,
    required this.colaborador,
    required this.rol,
    required this.estado,
    required this.fechaAlta,
    this.permisos = const [],
  });

  @override
  AsignacionCuidado copyWith({
    int? id,
    Persona? personaCuidada,
    Persona? colaborador,
    RolCuidado? rol,
    EstadoAsignacionCuidado? estado,
    DateTime? fechaAlta,
    List<PermisoCuidado>? permisos,
  }) {
    return AsignacionCuidado(
      id: id ?? this.id,
      personaCuidada: personaCuidada ?? this.personaCuidada,
      colaborador: colaborador ?? this.colaborador,
      rol: rol ?? this.rol,
      estado: estado ?? this.estado,
      fechaAlta: fechaAlta ?? this.fechaAlta,
      permisos: permisos ?? this.permisos,
    );
  }
}
