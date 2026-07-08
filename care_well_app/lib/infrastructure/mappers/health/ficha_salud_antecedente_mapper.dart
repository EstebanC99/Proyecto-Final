import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

class FichaSaludAntecedenteMapper {
  FichaSaludAntecedenteMapper._();

  static FichaSaludAntecedente fromModel(FichaSaludAntecedenteModel model) {
    return FichaSaludAntecedente(
      id: model.id,
      nombre: model.nombre,
      descripcion: model.descripcion,
      vinculoFamiliar: model.vinculoFamiliar,
    );
  }

  static FichaSaludAntecedenteModel toModel(FichaSaludAntecedente entity) {
    return FichaSaludAntecedenteModel(
      id: entity.id,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      vinculoFamiliar: entity.vinculoFamiliar,
    );
  }
}
