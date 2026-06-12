import 'dart:convert';

/// DTO de [FichaSalud] para serialización JSON.
class FichaSaludModel {
  final String id;
  final String personaId;
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
      id: json['id'] as String,
      personaId: json['personaId'] as String,
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

/// DTO de [HabitoDeVida] para serialización JSON.
class HabitoDeVidaModel {
  final String id;
  final String personaId;

  /// Tipo: 'actividadFisica', 'alimentacion', 'sueno', 'hidratacion', 'otro'.
  final String tipo;
  final String descripcion;

  const HabitoDeVidaModel({
    required this.id,
    required this.personaId,
    required this.tipo,
    required this.descripcion,
  });

  factory HabitoDeVidaModel.fromJson(Map<String, dynamic> json) {
    return HabitoDeVidaModel(
      id: json['id'] as String,
      personaId: json['personaId'] as String,
      tipo: json['tipo'] as String,
      descripcion: json['descripcion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personaId': personaId,
      'tipo': tipo,
      'descripcion': descripcion,
    };
  }

  factory HabitoDeVidaModel.fromRawJson(String source) =>
      HabitoDeVidaModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}

/// DTO de [RecomendacionMedica] para serialización JSON.
class RecomendacionMedicaModel {
  final String id;
  final String personaId;
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
      id: json['id'] as String,
      personaId: json['personaId'] as String,
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

/// DTO de [EventoDeSalud] para serialización JSON.
class EventoDeSaludModel {
  final String id;
  final String personaId;

  /// Tipo: 'sintoma', 'diagnostico', 'hospitalizacion', 'procedimiento', 'vacuna', 'otro'.
  final String tipo;
  final String fecha;
  final String descripcion;

  const EventoDeSaludModel({
    required this.id,
    required this.personaId,
    required this.tipo,
    required this.fecha,
    required this.descripcion,
  });

  factory EventoDeSaludModel.fromJson(Map<String, dynamic> json) {
    return EventoDeSaludModel(
      id: json['id'] as String,
      personaId: json['personaId'] as String,
      tipo: json['tipo'] as String,
      fecha: json['fecha'] as String,
      descripcion: json['descripcion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personaId': personaId,
      'tipo': tipo,
      'fecha': fecha,
      'descripcion': descripcion,
    };
  }

  factory EventoDeSaludModel.fromRawJson(String source) =>
      EventoDeSaludModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}

/// DTO de [EstadoDeAnimo] para serialización JSON.
class EstadoDeAnimoModel {
  final String id;
  final String personaId;
  final String? eventoDeSaludId;
  final String fecha;

  /// Estado: 'muyBien', 'bien', 'regular', 'mal', 'muyMal'.
  final String estado;
  final String? observaciones;

  const EstadoDeAnimoModel({
    required this.id,
    required this.personaId,
    this.eventoDeSaludId,
    required this.fecha,
    required this.estado,
    this.observaciones,
  });

  factory EstadoDeAnimoModel.fromJson(Map<String, dynamic> json) {
    return EstadoDeAnimoModel(
      id: json['id'] as String,
      personaId: json['personaId'] as String,
      eventoDeSaludId: json['eventoDeSaludId'] as String?,
      fecha: json['fecha'] as String,
      estado: json['estado'] as String,
      observaciones: json['observaciones'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personaId': personaId,
      if (eventoDeSaludId != null) 'eventoDeSaludId': eventoDeSaludId,
      'fecha': fecha,
      'estado': estado,
      if (observaciones != null) 'observaciones': observaciones,
    };
  }

  factory EstadoDeAnimoModel.fromRawJson(String source) =>
      EstadoDeAnimoModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}
