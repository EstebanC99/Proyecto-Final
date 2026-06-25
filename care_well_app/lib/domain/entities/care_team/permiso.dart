import '../base_entity.dart';

/// Código canónico de permiso (catálogo persistido).
///
/// Cada instancia representa una acción concreta que puede habilitarse
/// sobre una [AsignacionCuidado].
class CodigoPermiso extends BaseEntity {
  final String descripcion;

  const CodigoPermiso({required super.id, required this.descripcion});

  @override
  CodigoPermiso copyWith({int? id, String? descripcion}) {
    return CodigoPermiso(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
    );
  }
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
  Permiso copyWith({int? id, CodigoPermiso? codigo, String? descripcion}) {
    return Permiso(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
