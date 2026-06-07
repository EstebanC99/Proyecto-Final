/// Clase base abstracta para todas las entidades de dominio.
///
/// Garantiza que toda entidad tenga un [id] único e implementa
/// igualdad por identidad de tipo e [id], y [hashCode] consistente.
/// Las subclases deben implementar [copyWith] con la firma tipada correcta.
abstract class BaseEntity {
  final String id;

  const BaseEntity({required this.id});

  BaseEntity copyWith();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType && other is BaseEntity && other.id == id;

  @override
  int get hashCode => Object.hash(runtimeType, id);
}
