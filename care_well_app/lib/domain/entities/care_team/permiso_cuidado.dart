import 'package:care_well_app/domain/entities/base_entity.dart';

class PermisoCuidado extends BaseEntity {
  final String descripcion;

  const PermisoCuidado({required super.id, required this.descripcion});

  @override
  PermisoCuidado copyWith({int? id, String? descripcion}) {
    return PermisoCuidado(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
