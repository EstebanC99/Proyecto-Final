import '../../domain/entities/entities.dart';
import '../models/models.dart';

/// Convierte entre [UsuarioModel] (DTO) y [Usuario] (entidad de dominio).
class UsuarioMapper {
  UsuarioMapper._();

  static const _estadoMap = {
    'activo': EstadoUsuario.activo,
    'suspendido': EstadoUsuario.suspendido,
    'eliminado': EstadoUsuario.eliminado,
  };

  static const _estadoReverseMap = {
    EstadoUsuario.activo: 'activo',
    EstadoUsuario.suspendido: 'suspendido',
    EstadoUsuario.eliminado: 'eliminado',
  };

  /// Convierte un [UsuarioModel] en una entidad [Usuario].
  ///
  /// Requiere la [persona] ya construida (el modelo solo transporta el id).
  static Usuario fromModel(UsuarioModel model, Persona persona) {
    return Usuario(
      id: model.id,
      persona: persona,
      nombreUsuario: model.nombreUsuario,
      contrasenaHash: model.contrasenaHash,
      estado: _estadoMap[model.estado] ?? EstadoUsuario.activo,
    );
  }

  /// Convierte una entidad [Usuario] en un [UsuarioModel].
  static UsuarioModel toModel(Usuario entity) {
    return UsuarioModel(
      id: entity.id,
      personaId: entity.persona.id,
      nombreUsuario: entity.nombreUsuario,
      contrasenaHash: entity.contrasenaHash,
      estado: _estadoReverseMap[entity.estado] ?? 'activo',
    );
  }
}
