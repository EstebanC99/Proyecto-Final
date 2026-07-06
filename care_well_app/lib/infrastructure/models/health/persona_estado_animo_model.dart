import 'dart:convert';

import 'package:care_well_app/infrastructure/models/models.dart';

/// DTO de `PersonaEstadoAnimoDataView` para serialización JSON.
///
/// El backend devuelve [estadoAnimo] como objeto catálogo `{id, descripcion}`
/// y la [fechaHora] la fija el servidor.
class PersonaEstadoAnimoModel {
  final int id;
  final EstadoAnimoModel estadoAnimo;
  final String fechaHora;
  final String? observaciones;

  const PersonaEstadoAnimoModel({
    required this.id,
    required this.estadoAnimo,
    required this.fechaHora,
    this.observaciones,
  });

  factory PersonaEstadoAnimoModel.fromJson(Map<String, dynamic> json) =>
      PersonaEstadoAnimoModel(
        id: json['id'] as int,
        estadoAnimo: EstadoAnimoModel.fromJson(
          json['estadoAnimo'] as Map<String, dynamic>,
        ),
        fechaHora: json['fechaHora'] as String,
        observaciones: json['observaciones'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'estadoAnimo': estadoAnimo.toJson(),
    'fechaHora': fechaHora,
    if (observaciones != null) 'observaciones': observaciones,
  };

  factory PersonaEstadoAnimoModel.fromRawJson(String source) =>
      PersonaEstadoAnimoModel.fromJson(
        json.decode(source) as Map<String, dynamic>,
      );

  String toRawJson() => json.encode(toJson());
}
