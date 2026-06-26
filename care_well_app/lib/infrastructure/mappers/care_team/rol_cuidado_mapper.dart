import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/care_team/rol_cuidado_model.dart';

class RolCuidadoMapper {
  static RolCuidado fromModel(RolCuidadoModel model) {
    return RolCuidado(id: model.id, descripcion: model.descripcion);
  }
}
