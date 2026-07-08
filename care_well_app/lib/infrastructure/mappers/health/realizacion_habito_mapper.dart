import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

/// Convierte entre [HabitoVidaRealizacionModel] y [RealizacionHabitoVida].
class RealizacionHabitoMapper {
  RealizacionHabitoMapper._();

  /// [habitoId] se toma del hábito padre, no del JSON (evita depender del casing
  /// del acrónimo "ID" en la serialización del backend).
  static RealizacionHabitoVida fromModel(
    HabitoVidaRealizacionModel model, {
    required int habitoId,
  }) {
    return RealizacionHabitoVida(
      id: model.id,
      habitoId: habitoId,
      fechaHora: DateTime.parse(model.fechaHoraRealizacion),
      comentarios: model.comentarios,
    );
  }
}
