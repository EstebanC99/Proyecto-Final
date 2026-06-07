import '../auth/usuario.dart';
import '../base_entity.dart';

/// Preferencias de la app para un [Usuario] concreto.
class Configuracion extends BaseEntity {
  /// Usuario al que pertenece esta configuración.
  final Usuario usuario;

  /// Indica si el usuario tiene habilitadas las notificaciones push/locales.
  final bool notificacionesHabilitadas;

  /// Código de idioma (p. ej. `'es'`, `'en'`).
  final String idioma;

  const Configuracion({
    required super.id,
    required this.usuario,
    this.notificacionesHabilitadas = true,
    this.idioma = 'es',
  });

  @override
  Configuracion copyWith({
    String? id,
    Usuario? usuario,
    bool? notificacionesHabilitadas,
    String? idioma,
  }) {
    return Configuracion(
      id: id ?? this.id,
      usuario: usuario ?? this.usuario,
      notificacionesHabilitadas:
          notificacionesHabilitadas ?? this.notificacionesHabilitadas,
      idioma: idioma ?? this.idioma,
    );
  }
}
