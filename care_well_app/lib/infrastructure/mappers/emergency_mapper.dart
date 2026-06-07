import '../../domain/entities/entities.dart';
import '../models/models.dart';

/// Convierte entre [EmergenciaModel] y [Emergencia].
class EmergenciaMapper {
  EmergenciaMapper._();

  /// Requiere la [persona] ya construida (el modelo solo transporta el id).
  static Emergencia fromModel(EmergenciaModel model, Persona persona) {
    return Emergencia(
      id: model.id,
      persona: persona,
      fechaHora: DateTime.parse(model.fechaHora),
      atendida: model.atendida,
      descripcion: model.descripcion,
    );
  }

  static EmergenciaModel toModel(Emergencia entity) {
    return EmergenciaModel(
      id: entity.id,
      personaId: entity.persona.id,
      fechaHora: entity.fechaHora.toIso8601String(),
      atendida: entity.atendida,
      descripcion: entity.descripcion,
    );
  }
}
