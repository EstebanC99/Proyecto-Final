import 'package:care_well_app/domain/entities/entities.dart';

class EstadoUsuario extends BaseEntity {
  final String descripcion;

  EstadoUsuario({required super.id, required this.descripcion});

  @override
  EstadoUsuario copyWith({int? id, String? descripcion}) {
    return EstadoUsuario(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
