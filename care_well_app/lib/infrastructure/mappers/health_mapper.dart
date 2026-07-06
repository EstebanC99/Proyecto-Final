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
