import '../../domain/entities/entities.dart';
import '../models/models.dart';

/// Convierte [PersonaApiModel] → [Persona].
class PersonaApiMapper {
  PersonaApiMapper._();

  static Persona fromModel(PersonaApiModel model) => Persona(
    id: model.id,
    nombre: model.nombre,
    apellido: model.apellido,
    documento: model.documento,
    fechaNacimiento: model.fechaNacimiento != null
        ? DateTime.tryParse(model.fechaNacimiento!)
        : null,
    email: model.email,
    telefono: model.telefono,
    imagen: model.imagenPath,
  );
}

/// Convierte [AsignacionCuidadoApiModel] → [AsignacionCuidado].
class AsignacionCuidadoApiMapper {
  AsignacionCuidadoApiMapper._();

  static AsignacionCuidado fromModel(AsignacionCuidadoApiModel model) {
    final permisos = model.permisos
        .map(
          (p) => Permiso(
            id: p.id,
            codigo: CodigoPermiso(id: p.id, descripcion: p.descripcion),
            descripcion: p.descripcion,
          ),
        )
        .toList();

    return AsignacionCuidado(
      id: model.id,
      personaCuidada: PersonaApiMapper.fromModel(model.persona),
      personaColaborador: PersonaApiMapper.fromModel(model.colaborador),
      rol: RolCuidado(id: model.rol.id, descripcion: model.rol.descripcion),
      estado: EstadoAsignacion(
        id: model.estado.id,
        descripcion: model.estado.descripcion,
      ),
      fechaAlta: DateTime.parse(model.fechaAlta),
      permisos: permisos,
    );
  }
}
