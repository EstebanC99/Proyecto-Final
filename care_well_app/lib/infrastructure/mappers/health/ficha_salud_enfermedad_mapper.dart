import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

class FichaSaludEnfermedadMapper {
  FichaSaludEnfermedadMapper._();

  static FichaSaludEnfermedad fromModel(FichaSaludEnfermedadModel model) {
    return FichaSaludEnfermedad(
      id: model.id,
      nombre: model.nombre,
      vigente: model.vigente,
      observacion: model.observacion,
    );
  }

  static FichaSaludEnfermedadModel toModel(FichaSaludEnfermedad entity) {
    return FichaSaludEnfermedadModel(
      id: entity.id,
      nombre: entity.nombre,
      vigente: entity.vigente,
      observacion: entity.observacion,
    );
  }
}
