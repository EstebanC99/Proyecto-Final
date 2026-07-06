import '../base_entity.dart';

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
