import 'package:care_well_app/domain/entities/base_entity.dart';

class EstadoAsignacionCuidado extends BaseEntity {
  final String descripcion;

  const EstadoAsignacionCuidado({required super.id, required this.descripcion});

  @override
  EstadoAsignacionCuidado copyWith({int? id, String? descripcion}) {
    return EstadoAsignacionCuidado(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
