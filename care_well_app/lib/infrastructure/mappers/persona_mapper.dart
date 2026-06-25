import '../../domain/entities/entities.dart';
import '../models/models.dart';

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
      imagen: null,
    );
  }
}
