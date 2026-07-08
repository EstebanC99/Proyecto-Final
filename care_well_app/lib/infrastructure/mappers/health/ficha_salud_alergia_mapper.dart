import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

class FichaSaludAlergiaMapper {
  FichaSaludAlergiaMapper._();

  static FichaSaludAlergia fromModel(FichaSaludAlergiaModel model) {
    return FichaSaludAlergia(
      id: model.id,
      nombre: model.nombre,
      reaccion: model.reaccion,
      medicamento: model.medicamento,
    );
  }

  static FichaSaludAlergiaModel toModel(FichaSaludAlergia entity) {
    return FichaSaludAlergiaModel(
      id: entity.id,
      nombre: entity.nombre,
      reaccion: entity.reaccion,
      medicamento: entity.medicamento,
    );
  }
}
