import 'dart:convert';

/// DTO de una referencia embebida `{id, descripcion}`.
class EntidadBasicaModel {
  final int id;
  final String descripcion;

  const EntidadBasicaModel({required this.id, required this.descripcion});

  factory EntidadBasicaModel.fromJson(Map<String, dynamic> json) =>
      EntidadBasicaModel(
        id: json['id'] as int,
        descripcion: (json['descripcion'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'descripcion': descripcion};
}

/// DTO del catálogo [TipoHabito] para serialización JSON.
class TipoHabitoModel {
  final int id;
  final String descripcion;

  const TipoHabitoModel({required this.id, required this.descripcion});

  factory TipoHabitoModel.fromJson(Map<String, dynamic> json) =>
      TipoHabitoModel(
        id: json['id'] as int,
        descripcion: json['descripcion'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'descripcion': descripcion};
}

/// DTO del catálogo [TipoEventoSalud] para serialización JSON.
class TipoEventoSaludModel {
  final int id;
  final String descripcion;

  const TipoEventoSaludModel({required this.id, required this.descripcion});

  factory TipoEventoSaludModel.fromJson(Map<String, dynamic> json) =>
      TipoEventoSaludModel(
        id: json['id'] as int,
        descripcion: json['descripcion'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'descripcion': descripcion};
}

/// DTO del catálogo [EstadoAnimo] para serialización JSON.
class EstadoAnimoModel {
  final int id;
  final String descripcion;

  const EstadoAnimoModel({required this.id, required this.descripcion});

  factory EstadoAnimoModel.fromJson(Map<String, dynamic> json) =>
      EstadoAnimoModel(
        id: json['id'] as int,
        descripcion: json['descripcion'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'descripcion': descripcion};
}

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

/// DTO de [HabitoDeVida] para serialización JSON.
class HabitoDeVidaModel {
  final int id;
  final int personaId;

  /// Tipo como objeto catálogo.
  final TipoHabitoModel tipo;
  final String descripcion;

  const HabitoDeVidaModel({
    required this.id,
    required this.personaId,
    required this.tipo,
    required this.descripcion,
  });

  factory HabitoDeVidaModel.fromJson(Map<String, dynamic> json) {
    return HabitoDeVidaModel(
      id: json['id'] as int,
      personaId: json['personaId'] as int,
      tipo: TipoHabitoModel.fromJson(json['tipo'] as Map<String, dynamic>),
      descripcion: json['descripcion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personaId': personaId,
      'tipo': tipo.toJson(),
      'descripcion': descripcion,
    };
  }

  factory HabitoDeVidaModel.fromRawJson(String source) =>
      HabitoDeVidaModel.fromJson(json.decode(source) as Map<String, dynamic>);

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

/// DTO de [EventoDeSalud] para serialización JSON.
class EventoDeSaludModel {
  final int id;

  /// Persona como referencia embebida `{id, descripcion}`.
  final EntidadBasicaModel persona;

  /// Tipo como objeto catálogo.
  final TipoEventoSaludModel tipo;
  final String fechaHora;
  final String descripcion;

  /// Notas embebidas del evento.
  final List<NotaEventoModel> notas;

  /// Fecha/hora de la ocurrencia de agenda que originó el evento, si aplica.
  final String? fechaOcurrenciaEventoAgenda;

  const EventoDeSaludModel({
    required this.id,
    required this.persona,
    required this.tipo,
    required this.fechaHora,
    required this.descripcion,
    this.notas = const [],
    this.fechaOcurrenciaEventoAgenda,
  });

  factory EventoDeSaludModel.fromJson(Map<String, dynamic> json) {
    final notasJson = json['notas'] as List<dynamic>?;
    return EventoDeSaludModel(
      id: json['id'] as int,
      persona: EntidadBasicaModel.fromJson(
        json['persona'] as Map<String, dynamic>,
      ),
      tipo: TipoEventoSaludModel.fromJson(json['tipo'] as Map<String, dynamic>),
      fechaHora: json['fechaHora'] as String,
      descripcion: json['descripcion'] as String,
      notas:
          notasJson
              ?.map((e) => NotaEventoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fechaOcurrenciaEventoAgenda:
          json['fechaOcurrenciaEventoAgenda'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'persona': persona.toJson(),
      'tipo': tipo.toJson(),
      'fechaHora': fechaHora,
      'descripcion': descripcion,
      'notas': notas.map((n) => n.toJson()).toList(),
      if (fechaOcurrenciaEventoAgenda != null)
        'fechaOcurrenciaEventoAgenda': fechaOcurrenciaEventoAgenda,
    };
  }

  factory EventoDeSaludModel.fromRawJson(String source) =>
      EventoDeSaludModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}

/// DTO de [EstadoDeAnimo] para serialización JSON.
class EstadoDeAnimoModel {
  final int id;
  final int personaId;
  final int? eventoDeSaludId;
  final String fecha;

  /// Estado como objeto catálogo.
  final EstadoAnimoModel estado;
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
      id: json['id'] as int,
      personaId: json['personaId'] as int,
      eventoDeSaludId: json['eventoDeSaludId'] as int?,
      fecha: json['fecha'] as String,
      estado: EstadoAnimoModel.fromJson(json['estado'] as Map<String, dynamic>),
      observaciones: json['observaciones'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personaId': personaId,
      if (eventoDeSaludId != null) 'eventoDeSaludId': eventoDeSaludId,
      'fecha': fecha,
      'estado': estado.toJson(),
      if (observaciones != null) 'observaciones': observaciones,
    };
  }

  factory EstadoDeAnimoModel.fromRawJson(String source) =>
      EstadoDeAnimoModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}

/// DTO de [NotaEvento] para serialización JSON.
class NotaEventoModel {
  final int id;
  final int eventoSaludId;

  /// Autor como referencia embebida `{id, descripcion}`.
  final EntidadBasicaModel autor;
  final String fechaHora;
  final String contenido;

  const NotaEventoModel({
    required this.id,
    required this.eventoSaludId,
    required this.autor,
    required this.fechaHora,
    required this.contenido,
  });

  factory NotaEventoModel.fromJson(Map<String, dynamic> json) {
    return NotaEventoModel(
      id: json['id'] as int,
      eventoSaludId: (json['eventoSaludId'] as int?) ?? 0,
      autor: EntidadBasicaModel.fromJson(json['autor'] as Map<String, dynamic>),
      fechaHora: json['fechaHora'] as String,
      contenido: json['contenido'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventoSaludId': eventoSaludId,
      'autor': autor.toJson(),
      'fechaHora': fechaHora,
      'contenido': contenido,
    };
  }

  factory NotaEventoModel.fromRawJson(String source) =>
      NotaEventoModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}
