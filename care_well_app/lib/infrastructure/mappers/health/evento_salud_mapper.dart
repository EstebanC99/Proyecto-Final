import 'package:care_well_app/domain/entities/health/evento_de_salud.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

/// Convierte entre [EventoSaludModel] y [EventoSalud].
class EventoSaludMapper {
  EventoSaludMapper._();

  static EventoSalud fromModel(EventoSaludModel model) {
    return EventoSalud(
      id: model.id,
      persona: EntidadBasicaMapper.fromModel(model.persona),
      tipo: TipoEventoSaludMapper.fromModel(model.tipo),
      fechaHora: DateTime.parse(model.fechaHora),
      descripcion: model.descripcion,
      notas: model.notas.map(NotaEventoSaludMapper.fromModel).toList(),
      fechaOcurrenciaEventoAgenda: model.fechaOcurrenciaEventoAgenda == null
          ? null
          : DateTime.tryParse(model.fechaOcurrenciaEventoAgenda!),
    );
  }

  static EventoSaludModel toModel(EventoSalud entity) {
    return EventoSaludModel(
      id: entity.id,
      persona: EntidadBasicaMapper.toModel(entity.persona),
      tipo: TipoEventoSaludMapper.toModel(entity.tipo),
      fechaHora: entity.fechaHora.toIso8601String(),
      descripcion: entity.descripcion,
      notas: entity.notas.map(NotaEventoSaludMapper.toModel).toList(),
      fechaOcurrenciaEventoAgenda: entity.fechaOcurrenciaEventoAgenda
          ?.toIso8601String(),
    );
  }
}
