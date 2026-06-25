import 'dart:convert';

/// DTO de [Emergencia] para serialización JSON.
class EmergenciaModel {
  final int id;
  final int personaId;
  final String fechaHora;
  final bool atendida;
  final String? descripcion;

  const EmergenciaModel({
    required this.id,
    required this.personaId,
    required this.fechaHora,
    this.atendida = false,
    this.descripcion,
  });

  factory EmergenciaModel.fromJson(Map<String, dynamic> json) {
    return EmergenciaModel(
      id: json['id'] as int,
      personaId: json['personaId'] as int,
      fechaHora: json['fechaHora'] as String,
      atendida: (json['atendida'] as bool?) ?? false,
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personaId': personaId,
      'fechaHora': fechaHora,
      'atendida': atendida,
      if (descripcion != null) 'descripcion': descripcion,
    };
  }

  factory EmergenciaModel.fromRawJson(String source) =>
      EmergenciaModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}
