import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/health/realizacion_habito_mapper.dart';
import 'package:care_well_app/infrastructure/mappers/shared/entidad_basica_mapper.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

/// Convierte entre [HabitoVidaModel] y [HabitoVida].
class HabitoVidaMapper {
  HabitoVidaMapper._();

  static HabitoVida fromModel(HabitoVidaModel model) {
    return HabitoVida(
      id: model.id,
      persona: EntidadBasicaMapper.fromModel(model.persona),
      tipo: TipoHabitoVida(
        id: model.tipo.id,
        descripcion: model.tipo.descripcion,
      ),
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
