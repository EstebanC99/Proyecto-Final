import '../base_entity.dart';
import '../shared/persona.dart';

/// Tipo de hábito de vida.
enum TipoHabito {
  /// Actividad física.
  actividadFisica,

  /// Alimentación y dieta.
  alimentacion,

  /// Hábitos de sueño.
  sueno,

  /// Hidratación diaria.
  hidratacion,

  /// Otro hábito no categorizado.
  otro,
}

/// Hábito de vida registrado para una persona.
class HabitoDeVida extends BaseEntity {
  /// Persona a la que pertenece este hábito.
  final Persona persona;

  final TipoHabito tipo;
  final String descripcion;

  const HabitoDeVida({
    required super.id,
    required this.persona,
    required this.tipo,
    required this.descripcion,
  });

  @override
  HabitoDeVida copyWith({
    String? id,
    Persona? persona,
    TipoHabito? tipo,
    String? descripcion,
  }) {
    return HabitoDeVida(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
