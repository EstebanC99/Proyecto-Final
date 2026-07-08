import 'package:care_well_app/infrastructure/models/models.dart';

class FichaSaludModel {
  final int id;
  final int personaId;
  final String factorSanguineo;
  final String? obraSocial;
  final String? observaciones;
  final List<FichaSaludAntecedenteModel> antecedentes;
  final List<FichaSaludAlergiaModel> alergias;
  final List<FichaSaludEnfermedadModel> enfermedades;

  const FichaSaludModel({
    required this.id,
    required this.personaId,
    required this.factorSanguineo,
    this.obraSocial,
    this.observaciones,
    this.antecedentes = const [],
    this.alergias = const [],
    this.enfermedades = const [],
  });

  factory FichaSaludModel.fromJson(Map<String, dynamic> json) {
    return FichaSaludModel(
      id: json['id'] as int,
      personaId: (json['persona'] as Map<String, dynamic>?)?['id'] as int? ?? 0,
      factorSanguineo: json['factorSanguineo'] as String,
      obraSocial: json['obraSocial'] as String?,
      observaciones: json['observaciones'] as String?,
      antecedentes:
          (json['antecedentes'] as List<dynamic>?)
              ?.map(
                (e) => FichaSaludAntecedenteModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      alergias:
          (json['alergias'] as List<dynamic>?)
              ?.map(
                (e) =>
                    FichaSaludAlergiaModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      enfermedades:
          (json['enfermedades'] as List<dynamic>?)
              ?.map(
                (e) => FichaSaludEnfermedadModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'personaId': personaId,
    'factorSanguineo': factorSanguineo,
    if (obraSocial != null) 'obraSocial': obraSocial,
    if (observaciones != null) 'observaciones': observaciones,
    'antecedentes': antecedentes.map((e) => e.toJson()).toList(),
    'alergias': alergias.map((e) => e.toJson()).toList(),
    'enfermedades': enfermedades.map((e) => e.toJson()).toList(),
  };
}
