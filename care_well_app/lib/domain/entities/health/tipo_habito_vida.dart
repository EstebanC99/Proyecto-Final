import 'package:care_well_app/domain/entities/entities.dart';

class TipoHabitoVida extends BaseEntity {
  final String descripcion;

  const TipoHabitoVida({required super.id, required this.descripcion});

  @override
  TipoHabitoVida copyWith({int? id, String? descripcion}) {
    return TipoHabitoVida(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
