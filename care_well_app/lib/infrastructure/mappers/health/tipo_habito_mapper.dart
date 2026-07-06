import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

/// Convierte entre [TipoHabitoModel] y [TipoHabito].
class TipoHabitoMapper {
  TipoHabitoMapper._();

  static TipoHabitoVida fromModel(EntidadBasicaModel model) =>
      TipoHabitoVida(id: model.id, descripcion: model.descripcion);

  static EntidadBasicaModel toModel(TipoHabitoVida entity) =>
      EntidadBasicaModel(id: entity.id, descripcion: entity.descripcion);
}
