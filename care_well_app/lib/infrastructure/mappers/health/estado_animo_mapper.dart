import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

/// Convierte entre [EstadoAnimoModel] y [EstadoAnimo].
class EstadoAnimoMapper {
  EstadoAnimoMapper._();

  static EstadoAnimo fromModel(EstadoAnimoModel model) =>
      EstadoAnimo(id: model.id, descripcion: model.descripcion);

  static EstadoAnimoModel toModel(EstadoAnimo entity) =>
      EstadoAnimoModel(id: entity.id, descripcion: entity.descripcion);
}

/// Convierte [PersonaEstadoAnimoModel] a [PersonaEstadoAnimo].
class PersonaEstadoAnimoMapper {
  PersonaEstadoAnimoMapper._();

  static PersonaEstadoAnimo fromModel(
    PersonaEstadoAnimoModel model,
    Persona persona,
  ) {
    return PersonaEstadoAnimo(
      id: model.id,
      persona: persona,
      fecha: DateTime.parse(model.fechaHora),
      estado: EstadoAnimoMapper.fromModel(model.estadoAnimo),
      observaciones: model.observaciones,
    );
  }
}
