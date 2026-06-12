import '../../domain/entities/entities.dart';
import '../models/models.dart';

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

/// Convierte entre [HabitoDeVidaModel] y [HabitoDeVida].
class HabitoDeVidaMapper {
  HabitoDeVidaMapper._();

  static const _tipoMap = {
    'actividadFisica': TipoHabito.actividadFisica,
    'alimentacion': TipoHabito.alimentacion,
    'sueno': TipoHabito.sueno,
    'hidratacion': TipoHabito.hidratacion,
    'otro': TipoHabito.otro,
  };

  static const _tipoReverseMap = {
    TipoHabito.actividadFisica: 'actividadFisica',
    TipoHabito.alimentacion: 'alimentacion',
    TipoHabito.sueno: 'sueno',
    TipoHabito.hidratacion: 'hidratacion',
    TipoHabito.otro: 'otro',
  };

  /// Requiere la [persona] ya construida (el modelo solo transporta el id).
  static HabitoDeVida fromModel(HabitoDeVidaModel model, Persona persona) {
    return HabitoDeVida(
      id: model.id,
      persona: persona,
      tipo: _tipoMap[model.tipo] ?? TipoHabito.otro,
      descripcion: model.descripcion,
    );
  }

  static HabitoDeVidaModel toModel(HabitoDeVida entity) {
    return HabitoDeVidaModel(
      id: entity.id,
      personaId: entity.persona.id,
      tipo: _tipoReverseMap[entity.tipo] ?? 'otro',
      descripcion: entity.descripcion,
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

/// Convierte entre [EventoDeSaludModel] y [EventoDeSalud].
class EventoDeSaludMapper {
  EventoDeSaludMapper._();

  static const _tipoMap = {
    'citaMedica': TipoEventoSalud.citaMedica,
    'hospitalizacion': TipoEventoSalud.hospitalizacion,
    'medicacion': TipoEventoSalud.medicacion,
    'cirugia': TipoEventoSalud.cirugia,
    'tratamiento': TipoEventoSalud.tratamiento,
    'bienestar': TipoEventoSalud.bienestar,
    'sintoma': TipoEventoSalud.sintoma,
    'diagnostico': TipoEventoSalud.diagnostico,
    'vacuna': TipoEventoSalud.vacuna,
    // Alias de valores antiguos para compatibilidad de migración.
    'procedimiento': TipoEventoSalud.cirugia,
    'otro': TipoEventoSalud.otro,
  };

  static final _tipoReverseMap = {
    TipoEventoSalud.citaMedica: 'citaMedica',
    TipoEventoSalud.hospitalizacion: 'hospitalizacion',
    TipoEventoSalud.medicacion: 'medicacion',
    TipoEventoSalud.cirugia: 'cirugia',
    TipoEventoSalud.tratamiento: 'tratamiento',
    TipoEventoSalud.bienestar: 'bienestar',
    TipoEventoSalud.sintoma: 'sintoma',
    TipoEventoSalud.diagnostico: 'diagnostico',
    TipoEventoSalud.vacuna: 'vacuna',
    TipoEventoSalud.otro: 'otro',
  };

  /// Requiere la [persona] ya construida (el modelo solo transporta el id).
  static EventoDeSalud fromModel(EventoDeSaludModel model, Persona persona) {
    return EventoDeSalud(
      id: model.id,
      persona: persona,
      tipo: _tipoMap[model.tipo] ?? TipoEventoSalud.otro,
      fecha: DateTime.parse(model.fecha),
      descripcion: model.descripcion,
    );
  }

  static EventoDeSaludModel toModel(EventoDeSalud entity) {
    return EventoDeSaludModel(
      id: entity.id,
      personaId: entity.persona.id,
      tipo: _tipoReverseMap[entity.tipo] ?? 'otro',
      fecha: entity.fecha.toIso8601String(),
      descripcion: entity.descripcion,
    );
  }
}

/// Convierte entre [EstadoDeAnimoModel] y [EstadoDeAnimo].
class EstadoDeAnimoMapper {
  EstadoDeAnimoMapper._();

  static const _estadoMap = {
    'muyBien': EstadoAnimoEnum.muyBien,
    'bien': EstadoAnimoEnum.bien,
    'regular': EstadoAnimoEnum.regular,
    'mal': EstadoAnimoEnum.mal,
    'muyMal': EstadoAnimoEnum.muyMal,
  };

  static const _estadoReverseMap = {
    EstadoAnimoEnum.muyBien: 'muyBien',
    EstadoAnimoEnum.bien: 'bien',
    EstadoAnimoEnum.regular: 'regular',
    EstadoAnimoEnum.mal: 'mal',
    EstadoAnimoEnum.muyMal: 'muyMal',
  };

  /// Requiere la [persona] ya construida; [eventoDeSalud] es opcional.
  static EstadoDeAnimo fromModel(
    EstadoDeAnimoModel model,
    Persona persona, {
    EventoDeSalud? eventoDeSalud,
  }) {
    return EstadoDeAnimo(
      id: model.id,
      persona: persona,
      eventoDeSalud: eventoDeSalud,
      fecha: DateTime.parse(model.fecha),
      estado: _estadoMap[model.estado] ?? EstadoAnimoEnum.regular,
      observaciones: model.observaciones,
    );
  }

  static EstadoDeAnimoModel toModel(EstadoDeAnimo entity) {
    return EstadoDeAnimoModel(
      id: entity.id,
      personaId: entity.persona.id,
      eventoDeSaludId: entity.eventoDeSalud?.id,
      fecha: entity.fecha.toIso8601String(),
      estado: _estadoReverseMap[entity.estado] ?? 'regular',
      observaciones: entity.observaciones,
    );
  }
}
