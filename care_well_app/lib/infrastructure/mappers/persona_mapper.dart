import '../../domain/entities/entities.dart';
import '../models/models.dart';

/// Convierte entre [PersonaModel] (DTO) y [Persona] (entidad de dominio).
class PersonaMapper {
  PersonaMapper._();

  /// Convierte un [PersonaModel] en una entidad [Persona].
  static Persona fromModel(PersonaModel model) {
    return Persona(
      id: model.id,
      nombre: model.nombre,
      apellido: model.apellido,
      documento: model.documento,
      fechaNacimiento: model.fechaNacimiento != null
          ? DateTime.tryParse(model.fechaNacimiento!)
          : null,
      email: model.email,
      telefono: model.telefono,
      imagen: model.imagen,
    );
  }

  /// Convierte una entidad [Persona] en un [PersonaModel].
  static PersonaModel toModel(Persona entity) {
    return PersonaModel(
      id: entity.id,
      nombre: entity.nombre,
      apellido: entity.apellido,
      documento: entity.documento,
      fechaNacimiento: entity.fechaNacimiento?.toIso8601String(),
      email: entity.email,
      telefono: entity.telefono,
      imagen: entity.imagen,
    );
  }
}
