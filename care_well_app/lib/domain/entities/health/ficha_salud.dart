import 'package:care_well_app/domain/entities/entities.dart';

class FichaSalud extends BaseEntity {
  final Persona persona;
  final String factorSanguineo;
  final String? obraSocial;
  final String? observaciones;

  final List<FichaSaludAntecedente> antecedentes;
  final List<FichaSaludAlergia> alergias;
  final List<FichaSaludEnfermedad> enfermedades;

  const FichaSalud({
    super.id = 0,
    required this.persona,
    required this.factorSanguineo,
    this.obraSocial,
    this.observaciones,
    this.antecedentes = const [],
    this.alergias = const [],
    this.enfermedades = const [],
  });

  @override
  FichaSalud copyWith({
    int? id,
    Persona? persona,
    String? factorSanguineo,
    String? obraSocial,
    String? observaciones,
    List<FichaSaludAntecedente>? antecedentes,
    List<FichaSaludAlergia>? alergias,
    List<FichaSaludEnfermedad>? enfermedades,
  }) {
    return FichaSalud(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      factorSanguineo: factorSanguineo ?? this.factorSanguineo,
      obraSocial: obraSocial,
      observaciones: observaciones,
      antecedentes: antecedentes ?? this.antecedentes,
      alergias: alergias ?? this.alergias,
      enfermedades: enfermedades ?? this.enfermedades,
    );
  }
}
