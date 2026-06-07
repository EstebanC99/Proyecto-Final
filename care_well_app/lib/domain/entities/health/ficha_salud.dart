import '../base_entity.dart';
import '../shared/persona.dart';

/// Ficha de salud de una persona a cargo.
///
/// Contiene antecedentes clínicos y estudios realizados.
/// La relación es 1-a-0..1 con [Persona].
class FichaSalud extends BaseEntity {
  /// Persona a la que pertenece esta ficha de salud.
  final Persona persona;

  /// Antecedentes clínicos relevantes (texto libre).
  final String? antecedentes;

  /// Estudios médicos realizados (texto libre o lista serializada).
  final String? estudios;

  const FichaSalud({
    required super.id,
    required this.persona,
    this.antecedentes,
    this.estudios,
  });

  @override
  FichaSalud copyWith({
    String? id,
    Persona? persona,
    String? antecedentes,
    String? estudios,
  }) {
    return FichaSalud(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      antecedentes: antecedentes ?? this.antecedentes,
      estudios: estudios ?? this.estudios,
    );
  }
}
