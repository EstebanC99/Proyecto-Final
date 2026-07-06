import 'dart:convert';

import 'package:care_well_app/infrastructure/models/models.dart';

/// DTO de [HabitoDeVida] para serialización JSON.
///
/// El backend devuelve [persona] y [tipo] como `{id, descripcion}` (BaseEntityDataView).
class HabitoVidaModel {
  final int id;
  final EntidadBasicaModel persona;
  final EntidadBasicaModel tipo;
  final String descripcion;
  final bool activo;
  final HabitoVidaRealizacionModel? realizacion;

  const HabitoVidaModel({
    required this.id,
    required this.persona,
    required this.tipo,
    required this.descripcion,
    required this.activo,
    this.realizacion,
  });

  factory HabitoVidaModel.fromJson(Map<String, dynamic> json) {
    final realizacionJson = json['realizacion'] as Map<String, dynamic>?;
    return HabitoVidaModel(
      id: json['id'] as int,
      persona: EntidadBasicaModel.fromJson(
        json['persona'] as Map<String, dynamic>,
      ),
      tipo: EntidadBasicaModel.fromJson(json['tipo'] as Map<String, dynamic>),
      descripcion: json['descripcion'] as String,
      activo: json['activo'] as bool? ?? true,
      realizacion: realizacionJson != null
          ? HabitoVidaRealizacionModel.fromJson(realizacionJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'persona': persona.toJson(),
    'tipo': tipo.toJson(),
    'descripcion': descripcion,
    'activo': activo,
    if (realizacion != null) 'realizacion': realizacion!.toJson(),
  };

  factory HabitoVidaModel.fromRawJson(String source) =>
      HabitoVidaModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}
