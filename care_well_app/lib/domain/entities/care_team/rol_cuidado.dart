import '../base_entity.dart';

/// Tipo de rol dentro del equipo de cuidado (catálogo persistido).
///
/// - id 1: Responsable — gestiona la información de la persona a cargo y
///   administra el equipo.
/// - id 2: Cuidador — realiza tareas de cuidado; accede según permisos.
class RolCuidado extends BaseEntity {
  final String descripcion;

  const RolCuidado({required super.id, required this.descripcion});

  @override
  RolCuidado copyWith({int? id, String? descripcion}) {
    return RolCuidado(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
