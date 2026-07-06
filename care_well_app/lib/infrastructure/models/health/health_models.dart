import 'dart:convert';

/// DTO de [FichaSalud] para serialización JSON.
class FichaSaludModel {
  final int id;
  final int personaId;
  final String? antecedentes;
  final String? estudios;

  const FichaSaludModel({
    required this.id,
    required this.personaId,
    this.antecedentes,
    this.estudios,
  });

  factory FichaSaludModel.fromJson(Map<String, dynamic> json) {
    return FichaSaludModel(
      id: json['id'] as int,
      personaId: json['personaId'] as int,
      antecedentes: json['antecedentes'] as String?,
      estudios: json['estudios'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personaId': personaId,
      if (antecedentes != null) 'antecedentes': antecedentes,
      if (estudios != null) 'estudios': estudios,
    };
  }

  factory FichaSaludModel.fromRawJson(String source) =>
      FichaSaludModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}

/// DTO de [RecomendacionMedica] para serialización JSON.
class RecomendacionMedicaModel {
  final int id;
  final int personaId;
  final String descripcion;
  final String fecha;
  final String profesional;

  const RecomendacionMedicaModel({
    required this.id,
    required this.personaId,
    required this.descripcion,
    required this.fecha,
    required this.profesional,
  });

  factory RecomendacionMedicaModel.fromJson(Map<String, dynamic> json) {
    return RecomendacionMedicaModel(
      id: json['id'] as int,
      personaId: json['personaId'] as int,
      descripcion: json['descripcion'] as String,
      fecha: json['fecha'] as String,
      profesional: (json['profesional'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personaId': personaId,
      'descripcion': descripcion,
      'fecha': fecha,
      'profesional': profesional,
    };
  }

  factory RecomendacionMedicaModel.fromRawJson(String source) =>
      RecomendacionMedicaModel.fromJson(
        json.decode(source) as Map<String, dynamic>,
      );

  String toRawJson() => json.encode(toJson());
}
