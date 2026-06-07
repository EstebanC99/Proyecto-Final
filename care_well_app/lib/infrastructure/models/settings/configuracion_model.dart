import 'dart:convert';

/// DTO de [Configuracion] para serialización JSON.
class ConfiguracionModel {
  final String id;
  final String usuarioId;
  final bool notificacionesHabilitadas;
  final String idioma;

  const ConfiguracionModel({
    required this.id,
    required this.usuarioId,
    this.notificacionesHabilitadas = true,
    this.idioma = 'es',
  });

  factory ConfiguracionModel.fromJson(Map<String, dynamic> json) {
    return ConfiguracionModel(
      id: json['id'] as String,
      usuarioId: json['usuarioId'] as String,
      notificacionesHabilitadas:
          (json['notificacionesHabilitadas'] as bool?) ?? true,
      idioma: (json['idioma'] as String?) ?? 'es',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'notificacionesHabilitadas': notificacionesHabilitadas,
      'idioma': idioma,
    };
  }

  factory ConfiguracionModel.fromRawJson(String source) =>
      ConfiguracionModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}

/// DTO de [AceptacionTerminos] para serialización JSON.
class AceptacionTerminosModel {
  final String id;
  final String usuarioId;
  final String version;
  final String fechaAceptacion;

  const AceptacionTerminosModel({
    required this.id,
    required this.usuarioId,
    required this.version,
    required this.fechaAceptacion,
  });

  factory AceptacionTerminosModel.fromJson(Map<String, dynamic> json) {
    return AceptacionTerminosModel(
      id: json['id'] as String,
      usuarioId: json['usuarioId'] as String,
      version: json['version'] as String,
      fechaAceptacion: json['fechaAceptacion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'version': version,
      'fechaAceptacion': fechaAceptacion,
    };
  }

  factory AceptacionTerminosModel.fromRawJson(String source) =>
      AceptacionTerminosModel.fromJson(
        json.decode(source) as Map<String, dynamic>,
      );

  String toRawJson() => json.encode(toJson());
}
