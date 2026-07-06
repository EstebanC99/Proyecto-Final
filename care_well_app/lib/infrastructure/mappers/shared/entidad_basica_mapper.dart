import 'package:care_well_app/domain/entities/shared/entidad_basica.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

/// Convierte entre [EntidadBasicaModel] y [EntidadBasica].
class EntidadBasicaMapper {
  EntidadBasicaMapper._();

  static EntidadBasica fromModel(EntidadBasicaModel model) =>
      EntidadBasica(id: model.id, descripcion: model.descripcion);

  static EntidadBasicaModel toModel(EntidadBasica entity) =>
      EntidadBasicaModel(id: entity.id, descripcion: entity.descripcion);
}
