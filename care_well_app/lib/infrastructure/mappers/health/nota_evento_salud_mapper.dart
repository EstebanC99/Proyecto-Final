import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

/// Convierte entre [NotaEventoSaludModel] y [NotaEventoSalud].
class NotaEventoSaludMapper {
  NotaEventoSaludMapper._();

  static NotaEventoSalud fromModel(NotaEventoSaludModel model) {
    return NotaEventoSalud(
      id: model.id,
      eventoSaludId: model.eventoSaludId,
      autor: EntidadBasicaMapper.fromModel(model.autor),
      fechaHora: DateTime.parse(model.fechaHora),
      contenido: model.contenido,
    );
  }

  static NotaEventoSaludModel toModel(NotaEventoSalud entity) {
    return NotaEventoSaludModel(
      id: entity.id,
      eventoSaludId: entity.eventoSaludId,
      autor: EntidadBasicaMapper.toModel(entity.autor),
      fechaHora: entity.fechaHora.toIso8601String(),
      contenido: entity.contenido,
    );
  }
}
