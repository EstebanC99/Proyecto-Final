import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

class FichaSaludMapper {
  FichaSaludMapper._();

  static FichaSalud fromModel(FichaSaludModel model, Persona persona) {
    return FichaSalud(
      id: model.id,
      persona: persona,
      factorSanguineo: model.factorSanguineo,
      obraSocial: model.obraSocial,
      observaciones: model.observaciones,
      antecedentes: model.antecedentes
          .map(FichaSaludAntecedenteMapper.fromModel)
          .toList(),
      alergias: model.alergias.map(FichaSaludAlergiaMapper.fromModel).toList(),
      enfermedades: model.enfermedades
          .map(FichaSaludEnfermedadMapper.fromModel)
          .toList(),
    );
  }

  static FichaSaludModel toModel(FichaSalud entity) {
    return FichaSaludModel(
      id: entity.id,
      personaId: entity.persona.id,
      factorSanguineo: entity.factorSanguineo,
      obraSocial: entity.obraSocial,
      observaciones: entity.observaciones,
      antecedentes: entity.antecedentes
          .map(FichaSaludAntecedenteMapper.toModel)
          .toList(),
      alergias: entity.alergias.map(FichaSaludAlergiaMapper.toModel).toList(),
      enfermedades: entity.enfermedades
          .map(FichaSaludEnfermedadMapper.toModel)
          .toList(),
    );
  }
}
