import 'package:care_well_app/domain/entities/entities.dart';

class RealizacionHabitoVida extends BaseEntity {
  final int habitoId;
  final DateTime fechaHora;
  final String? comentarios;

  const RealizacionHabitoVida({
    required super.id,
    required this.habitoId,
    required this.fechaHora,
    this.comentarios,
  });

  @override
  RealizacionHabitoVida copyWith({
    int? id,
    int? habitoId,
    DateTime? fechaHora,
    String? comentarios,
  }) {
    return RealizacionHabitoVida(
      id: id ?? this.id,
      habitoId: habitoId ?? this.habitoId,
      fechaHora: fechaHora ?? this.fechaHora,
      comentarios: comentarios ?? this.comentarios,
    );
  }
}
