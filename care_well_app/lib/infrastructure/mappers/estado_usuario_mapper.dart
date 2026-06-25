import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

class EstadoUsuarioMapper {
  static EstadoUsuario fromModel(EstadoUsuarioModel model) =>
      EstadoUsuario(id: model.id, descripcion: model.descripcion);
}
