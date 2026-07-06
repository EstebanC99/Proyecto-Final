import 'package:care_well_app/domain/entities/entities.dart';

class EstadoAnimo extends BaseEntity {
  final String descripcion;

  const EstadoAnimo({required super.id, required this.descripcion});

  @override
  EstadoAnimo copyWith({int? id, String? descripcion}) {
    return EstadoAnimo(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
