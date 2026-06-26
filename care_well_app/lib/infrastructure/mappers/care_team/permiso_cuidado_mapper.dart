import 'package:care_well_app/domain/entities/care_team/permiso_cuidado.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

class PermisoCuidadoMapper {
  static PermisoCuidado fromModel(PermisoCuidadoModel model) {
    return PermisoCuidado(id: model.id, descripcion: model.descripcion);
  }
}
