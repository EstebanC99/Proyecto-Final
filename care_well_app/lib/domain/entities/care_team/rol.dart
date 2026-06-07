import '../base_entity.dart';
import 'permiso.dart';

/// Código de rol dentro del equipo de cuidado.
///
/// - [responsable]: gestiona la información de la persona a cargo y
///   administra el equipo.
/// - [cuidador]: realiza tareas de cuidado; accede según permisos.
enum RolCuidado { responsable, cuidador }

/// Rol dentro del equipo de cuidado con la lista de permisos asociados.
///
/// Se decide NO modelar [RolPermiso] como entidad separada: los permisos
/// se incluyen directamente en [Rol] para simplificar el dominio del cliente.
class Rol extends BaseEntity {
  /// Tipo de rol: [RolCuidado.responsable] o [RolCuidado.cuidador].
  final RolCuidado nombre;

  /// Permisos otorgados a este rol.
  final List<Permiso> permisos;

  const Rol({
    required super.id,
    required this.nombre,
    this.permisos = const [],
  });

  @override
  Rol copyWith({String? id, RolCuidado? nombre, List<Permiso>? permisos}) {
    return Rol(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      permisos: permisos ?? this.permisos,
    );
  }
}
