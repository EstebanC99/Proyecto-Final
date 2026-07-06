import 'package:care_well_app/domain/entities/entities.dart';

class HabitoVida extends BaseEntity {
  final EntidadBasica persona;
  final TipoHabitoVida tipo;
  final String descripcion;
  final RealizacionHabitoVida? realizacion;

  const HabitoVida({
    required super.id,
    required this.persona,
    required this.tipo,
    required this.descripcion,
    this.realizacion,
  });

  @override
  HabitoVida copyWith({
    int? id,
    EntidadBasica? persona,
    TipoHabitoVida? tipo,
    String? descripcion,
    RealizacionHabitoVida? realizacion,
  }) {
    return HabitoVida(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      realizacion: realizacion ?? this.realizacion,
    );
  }
}
