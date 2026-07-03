import '../base_entity.dart';

/// Referencia embebida mínima a una entidad de dominio: `{id, descripcion}`.
///
/// Se usa para relaciones que el backend transporta de forma resumida (por
/// ejemplo, la persona o el autor de una nota dentro de un evento de salud),
/// sin necesidad de traer la entidad completa. NO reemplaza a los catálogos
/// semánticos (TipoEvento, TipoHabito, EstadoAnimo, etc.).
class EntidadBasica extends BaseEntity {
  final String descripcion;

  const EntidadBasica({required super.id, required this.descripcion});

  @override
  EntidadBasica copyWith({int? id, String? descripcion}) => EntidadBasica(
    id: id ?? this.id,
    descripcion: descripcion ?? this.descripcion,
  );
}
