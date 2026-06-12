import '../base_entity.dart';

/// Código de rol dentro del equipo de cuidado.
///
/// - [responsable]: gestiona la información de la persona a cargo y
///   administra el equipo.
/// - [cuidador]: realiza tareas de cuidado; accede según permisos.
enum RolCuidado { responsable, cuidador }

/// Rol dentro del equipo de cuidado.
///
/// Los permisos NO se asocian al rol sino a cada [AsignacionCuidado],
/// alineado con el modelo de dominio del backend.
class Rol extends BaseEntity {
  /// Tipo de rol: [RolCuidado.responsable] o [RolCuidado.cuidador].
  final RolCuidado nombre;

  const Rol({required super.id, required this.nombre});

  @override
  Rol copyWith({String? id, RolCuidado? nombre}) {
    return Rol(id: id ?? this.id, nombre: nombre ?? this.nombre);
  }
}
