import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/care_team/estado_asignacion_cuidado_model.dart';

class EstadoAsignacionCuidadoMapper {
  static EstadoAsignacionCuidado fromModel(EstadoAsignacionCuidadoModel model) {
    return EstadoAsignacionCuidado(
      id: model.id,
      descripcion: model.descripcion,
    );
  }
}
