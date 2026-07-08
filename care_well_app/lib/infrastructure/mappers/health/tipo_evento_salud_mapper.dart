import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

/// Convierte entre [TipoEventoSaludModel] y [TipoEventoSalud].
class TipoEventoSaludMapper {
  TipoEventoSaludMapper._();

  static TipoEventoSalud fromModel(TipoEventoSaludModel model) =>
      TipoEventoSalud(id: model.id, descripcion: model.descripcion);

  static TipoEventoSaludModel toModel(TipoEventoSalud entity) =>
      TipoEventoSaludModel(id: entity.id, descripcion: entity.descripcion);
}
