import '../base_entity.dart';
import '../shared/persona.dart';

/// Tipo de hábito de vida (catálogo persistido).
///
/// - id 1: Actividad física.
/// - id 2: Alimentación y dieta.
/// - id 3: Hábitos de sueño.
/// - id 4: Hidratación diaria.
/// - id 5: Otro hábito no categorizado.
class TipoHabito extends BaseEntity {
  final String descripcion;

  const TipoHabito({required super.id, required this.descripcion});

  @override
  TipoHabito copyWith({int? id, String? descripcion}) {
    return TipoHabito(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
    );
  }
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
    int? id,
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
