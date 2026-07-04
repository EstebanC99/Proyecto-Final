import '../../domain/entities/entities.dart';
import '../models/models.dart';

/// Convierte entre [EntidadBasicaModel] y [EntidadBasica].
class EntidadBasicaMapper {
  EntidadBasicaMapper._();

  static EntidadBasica fromModel(EntidadBasicaModel model) =>
      EntidadBasica(id: model.id, descripcion: model.descripcion);

  static EntidadBasicaModel toModel(EntidadBasica entity) =>
      EntidadBasicaModel(id: entity.id, descripcion: entity.descripcion);
}

/// Convierte entre [FichaSaludModel] y [FichaSalud].
class FichaSaludMapper {
  FichaSaludMapper._();

  /// Requiere la [persona] ya construida (el modelo solo transporta el id).
  static FichaSalud fromModel(FichaSaludModel model, Persona persona) {
    return FichaSalud(
      id: model.id,
      persona: persona,
      antecedentes: model.antecedentes,
      estudios: model.estudios,
    );
  }

  static FichaSaludModel toModel(FichaSalud entity) {
    return FichaSaludModel(
      id: entity.id,
      personaId: entity.persona.id,
      antecedentes: entity.antecedentes,
      estudios: entity.estudios,
    );
  }
}

/// Convierte entre [TipoHabitoModel] y [TipoHabito].
class TipoHabitoMapper {
  TipoHabitoMapper._();

  static TipoHabito fromModel(TipoHabitoModel model) =>
      TipoHabito(id: model.id, descripcion: model.descripcion);

  static TipoHabitoModel toModel(TipoHabito entity) =>
      TipoHabitoModel(id: entity.id, descripcion: entity.descripcion);
}

/// Convierte entre [HabitoVidaRealizacionModel] y [RealizacionHabito].
class RealizacionHabitoMapper {
  RealizacionHabitoMapper._();

  /// [habitoId] se toma del hábito padre, no del JSON (evita depender del casing
  /// del acrónimo "ID" en la serialización del backend).
  static RealizacionHabito fromModel(
    HabitoVidaRealizacionModel model, {
    required int habitoId,
  }) {
    return RealizacionHabito(
      id: model.id,
      habitoId: habitoId,
      fechaHora: DateTime.parse(model.fechaHoraRealizacion),
      comentarios: model.comentarios,
    );
  }
}

/// Convierte entre [HabitoDeVidaModel] y [HabitoDeVida].
class HabitoDeVidaMapper {
  HabitoDeVidaMapper._();

  static HabitoDeVida fromModel(HabitoDeVidaModel model) {
    return HabitoDeVida(
      id: model.id,
      persona: EntidadBasicaMapper.fromModel(model.persona),
      tipo: TipoHabito(id: model.tipo.id, descripcion: model.tipo.descripcion),
      descripcion: model.descripcion,
      realizacion: model.realizacion != null
          ? RealizacionHabitoMapper.fromModel(
              model.realizacion!,
              habitoId: model.id,
            )
          : null,
    );
  }
}

/// Convierte entre [RecomendacionMedicaModel] y [RecomendacionMedica].
class RecomendacionMedicaMapper {
  RecomendacionMedicaMapper._();

  /// Requiere la [persona] ya construida (el modelo solo transporta el id).
  static RecomendacionMedica fromModel(
    RecomendacionMedicaModel model,
    Persona persona,
  ) {
    return RecomendacionMedica(
      id: model.id,
      persona: persona,
      descripcion: model.descripcion,
      fecha: DateTime.parse(model.fecha),
      profesional: model.profesional,
    );
  }

  static RecomendacionMedicaModel toModel(RecomendacionMedica entity) {
    return RecomendacionMedicaModel(
      id: entity.id,
      personaId: entity.persona.id,
      descripcion: entity.descripcion,
      fecha: entity.fecha.toIso8601String(),
      profesional: entity.profesional,
    );
  }
}

/// Convierte entre [TipoEventoSaludModel] y [TipoEventoSalud].
class TipoEventoSaludMapper {
  TipoEventoSaludMapper._();

  static TipoEventoSalud fromModel(TipoEventoSaludModel model) =>
      TipoEventoSalud(id: model.id, descripcion: model.descripcion);

  static TipoEventoSaludModel toModel(TipoEventoSalud entity) =>
      TipoEventoSaludModel(id: entity.id, descripcion: entity.descripcion);
}

/// Convierte entre [EventoDeSaludModel] y [EventoDeSalud].
class EventoDeSaludMapper {
  EventoDeSaludMapper._();

  static EventoDeSalud fromModel(EventoDeSaludModel model) {
    return EventoDeSalud(
      id: model.id,
      persona: EntidadBasicaMapper.fromModel(model.persona),
      tipo: TipoEventoSaludMapper.fromModel(model.tipo),
      fechaHora: DateTime.parse(model.fechaHora),
      descripcion: model.descripcion,
      notas: model.notas.map(NotaEventoMapper.fromModel).toList(),
      fechaOcurrenciaEventoAgenda: model.fechaOcurrenciaEventoAgenda == null
          ? null
          : DateTime.tryParse(model.fechaOcurrenciaEventoAgenda!),
    );
  }

  static EventoDeSaludModel toModel(EventoDeSalud entity) {
    return EventoDeSaludModel(
      id: entity.id,
      persona: EntidadBasicaMapper.toModel(entity.persona),
      tipo: TipoEventoSaludMapper.toModel(entity.tipo),
      fechaHora: entity.fechaHora.toIso8601String(),
      descripcion: entity.descripcion,
      notas: entity.notas.map(NotaEventoMapper.toModel).toList(),
      fechaOcurrenciaEventoAgenda: entity.fechaOcurrenciaEventoAgenda
          ?.toIso8601String(),
    );
  }
}

/// Convierte entre [EstadoAnimoModel] y [EstadoAnimo].
class EstadoAnimoMapper {
  EstadoAnimoMapper._();

  static EstadoAnimo fromModel(EstadoAnimoModel model) =>
      EstadoAnimo(id: model.id, descripcion: model.descripcion);

  static EstadoAnimoModel toModel(EstadoAnimo entity) =>
      EstadoAnimoModel(id: entity.id, descripcion: entity.descripcion);
}

/// Convierte [PersonaEstadoAnimoModel] a [EstadoDeAnimo].
class PersonaEstadoAnimoMapper {
  PersonaEstadoAnimoMapper._();

  /// Requiere la [persona] ya construida. Los DataViews de estos endpoints no
  /// traen evento de salud asociado, por lo que [EstadoDeAnimo.eventoDeSalud]
  /// queda siempre en `null`.
  static EstadoDeAnimo fromModel(
    PersonaEstadoAnimoModel model,
    Persona persona,
  ) {
    return EstadoDeAnimo(
      id: model.id,
      persona: persona,
      eventoDeSalud: null,
      fecha: DateTime.parse(model.fechaHora),
      estado: EstadoAnimoMapper.fromModel(model.estadoAnimo),
      observaciones: model.observaciones,
    );
  }
}

/// Convierte entre [NotaEventoModel] y [NotaEvento].
class NotaEventoMapper {
  NotaEventoMapper._();

  static NotaEvento fromModel(NotaEventoModel model) {
    return NotaEvento(
      id: model.id,
      eventoSaludId: model.eventoSaludId,
      autor: EntidadBasicaMapper.fromModel(model.autor),
      fechaHora: DateTime.parse(model.fechaHora),
      contenido: model.contenido,
    );
  }

  static NotaEventoModel toModel(NotaEvento entity) {
    return NotaEventoModel(
      id: entity.id,
      eventoSaludId: entity.eventoSaludId,
      autor: EntidadBasicaMapper.toModel(entity.autor),
      fechaHora: entity.fechaHora.toIso8601String(),
      contenido: entity.contenido,
    );
  }
}
