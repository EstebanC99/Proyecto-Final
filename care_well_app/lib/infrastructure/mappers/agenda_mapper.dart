import '../../domain/entities/entities.dart';
import '../models/models.dart';

/// Convierte entre [EventoAgendaModel] y [EventoAgenda].
class EventoAgendaMapper {
  EventoAgendaMapper._();

  static const _tipoMap = {
    'citaMedica': TipoEventoAgenda.citaMedica,
    'medicacion': TipoEventoAgenda.medicacion,
    'rehabilitacion': TipoEventoAgenda.rehabilitacion,
    'control': TipoEventoAgenda.control,
    'otro': TipoEventoAgenda.otro,
  };

  static const _tipoReverseMap = {
    TipoEventoAgenda.citaMedica: 'citaMedica',
    TipoEventoAgenda.medicacion: 'medicacion',
    TipoEventoAgenda.rehabilitacion: 'rehabilitacion',
    TipoEventoAgenda.control: 'control',
    TipoEventoAgenda.otro: 'otro',
  };

  /// Requiere la [persona] y el [creadoPor] ya construidos.
  static EventoAgenda fromModel(
    EventoAgendaModel model, {
    required Persona persona,
    required Usuario creadoPor,
  }) {
    return EventoAgenda(
      id: model.id,
      persona: persona,
      creadoPor: creadoPor,
      titulo: model.titulo,
      descripcion: model.descripcion,
      tipo: _tipoMap[model.tipo] ?? TipoEventoAgenda.otro,
      fechaHoraInicio: DateTime.parse(model.fechaHoraInicio),
      fechaHoraFin: model.fechaHoraFin != null
          ? DateTime.tryParse(model.fechaHoraFin!)
          : null,
    );
  }

  static EventoAgendaModel toModel(EventoAgenda entity) {
    return EventoAgendaModel(
      id: entity.id,
      personaId: entity.persona.id,
      creadoPorId: entity.creadoPor.id,
      titulo: entity.titulo,
      descripcion: entity.descripcion,
      tipo: _tipoReverseMap[entity.tipo] ?? 'otro',
      fechaHoraInicio: entity.fechaHoraInicio.toIso8601String(),
      fechaHoraFin: entity.fechaHoraFin?.toIso8601String(),
    );
  }
}

/// Convierte entre [RecordatorioModel] y [Recordatorio].
class RecordatorioMapper {
  RecordatorioMapper._();

  /// Requiere el [eventoAgenda] ya construido (el modelo solo transporta el id).
  static Recordatorio fromModel(
    RecordatorioModel model,
    EventoAgenda eventoAgenda,
  ) {
    return Recordatorio(
      id: model.id,
      eventoAgenda: eventoAgenda,
      fechaHoraEnvio: DateTime.parse(model.fechaHoraEnvio),
      enviado: model.enviado,
    );
  }

  static RecordatorioModel toModel(Recordatorio entity) {
    return RecordatorioModel(
      id: entity.id,
      eventoAgendaId: entity.eventoAgenda.id,
      fechaHoraEnvio: entity.fechaHoraEnvio.toIso8601String(),
      enviado: entity.enviado,
    );
  }
}
