import '../../domain/entities/entities.dart';
import '../models/models.dart';

/// Convierte entre [ConfiguracionModel] y [Configuracion].
class ConfiguracionMapper {
  ConfiguracionMapper._();

  /// Requiere el [usuario] ya construido (el modelo solo transporta el id).
  static Configuracion fromModel(ConfiguracionModel model, Usuario usuario) {
    return Configuracion(
      id: model.id,
      usuario: usuario,
      notificacionesHabilitadas: model.notificacionesHabilitadas,
      idioma: model.idioma,
    );
  }

  static ConfiguracionModel toModel(Configuracion entity) {
    return ConfiguracionModel(
      id: entity.id,
      usuarioId: entity.usuario.id,
      notificacionesHabilitadas: entity.notificacionesHabilitadas,
      idioma: entity.idioma,
    );
  }
}

/// Convierte entre [AceptacionTerminosModel] y [AceptacionTerminos].
class AceptacionTerminosMapper {
  AceptacionTerminosMapper._();

  /// Requiere el [usuario] ya construido (el modelo solo transporta el id).
  static AceptacionTerminos fromModel(
    AceptacionTerminosModel model,
    Usuario usuario,
  ) {
    return AceptacionTerminos(
      id: model.id,
      usuario: usuario,
      version: model.version,
      fechaAceptacion: DateTime.parse(model.fechaAceptacion),
    );
  }

  static AceptacionTerminosModel toModel(AceptacionTerminos entity) {
    return AceptacionTerminosModel(
      id: entity.id,
      usuarioId: entity.usuario.id,
      version: entity.version,
      fechaAceptacion: entity.fechaAceptacion.toIso8601String(),
    );
  }
}
