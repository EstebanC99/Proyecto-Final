import 'package:care_well_app/domain/entities/entities.dart';

class TipoEventoSalud extends BaseEntity {
  final String descripcion;

  const TipoEventoSalud({required super.id, required this.descripcion});

  @override
  TipoEventoSalud copyWith({int? id, String? descripcion}) {
    return TipoEventoSalud(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
