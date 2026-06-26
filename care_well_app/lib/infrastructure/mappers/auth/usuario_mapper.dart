import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

class UsuarioMapper {
  static Usuario fromModel(UsuarioModel model) => Usuario(
    id: model.id,
    contrasena: '',
    persona: PersonaMapper.fromModel(model.personaModel),
    estado: EstadoUsuarioMapper.fromModel(model.estadoModel),
  );
}
