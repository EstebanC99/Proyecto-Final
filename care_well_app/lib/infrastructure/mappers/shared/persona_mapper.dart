import 'package:care_well_app/domain/entities/shared/persona.dart';
import 'package:care_well_app/infrastructure/models/shared/persona_model.dart';

class PersonaMapper {
  static Persona fromModel(PersonaModel model) {
    return Persona(
      id: model.id,
      nombre: model.nombre,
      apellido: model.apellido,
      documento: model.documento,
      fechaNacimiento: model.fechaNacimiento,
      email: model.email,
      telefono: model.telefono,
      imagen: model.imagen,
    );
  }

  static PersonaModel toModel(Persona entity) {
    return PersonaModel(
      id: entity.id,
      nombre: entity.nombre,
      apellido: entity.apellido,
      documento: entity.documento,
      fechaNacimiento: entity.fechaNacimiento,
      email: entity.email,
      telefono: entity.telefono,
      imagen: entity.imagen,
    );
  }
}
