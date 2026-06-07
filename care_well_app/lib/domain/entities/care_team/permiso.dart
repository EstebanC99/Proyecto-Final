import '../base_entity.dart';

/// Código de permiso que puede otorgarse a un colaborador.
///
/// Cada [Permiso] habilita una acción concreta dentro de la app.
enum CodigoPermiso {
  /// Ver la ficha de salud de la persona a cargo.
  verFichaSalud,

  /// Editar la ficha de salud de la persona a cargo.
  editarFichaSalud,

  /// Ver y gestionar la agenda de la persona a cargo.
  gestionarAgenda,

  /// Registrar eventos de salud.
  registrarEventosSalud,

  /// Registrar hábitos de vida.
  registrarHabitos,

  /// Activar una emergencia.
  activarEmergencia,

  /// Administrar el equipo de cuidado (solo responsable).
  administrarEquipo,
}

/// Permiso individual que puede asociarse a un [Rol].
class Permiso extends BaseEntity {
  /// Código canónico del permiso.
  final CodigoPermiso codigo;

  /// Descripción legible para el usuario.
  final String descripcion;

  const Permiso({
    required super.id,
    required this.codigo,
    required this.descripcion,
  });

  @override
  Permiso copyWith({String? id, CodigoPermiso? codigo, String? descripcion}) {
    return Permiso(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
