import '../base_entity.dart';
import '../shared/entidad_basica.dart';

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

/// Registro de que un hábito fue realizado en una fecha/hora determinada.
///
/// Nota: para eliminar la realización de un [HabitoDeVida] no uses
/// `copyWith(realizacion: null)` — el patrón `?? this.x` no permite vaciar
/// campos opcionales. Construí un [HabitoDeVida] nuevo con `realizacion: null`
/// explícito.
class RealizacionHabito extends BaseEntity {
  final int habitoId;
  final DateTime fechaHora;
  final String? comentarios;

  const RealizacionHabito({
    required super.id,
    required this.habitoId,
    required this.fechaHora,
    this.comentarios,
  });

  @override
  RealizacionHabito copyWith({
    int? id,
    int? habitoId,
    DateTime? fechaHora,
    String? comentarios,
  }) {
    return RealizacionHabito(
      id: id ?? this.id,
      habitoId: habitoId ?? this.habitoId,
      fechaHora: fechaHora ?? this.fechaHora,
      comentarios: comentarios ?? this.comentarios,
    );
  }
}

/// Hábito de vida registrado para una persona.
class HabitoDeVida extends BaseEntity {
  /// Persona a la que pertenece este hábito.
  final EntidadBasica persona;

  final TipoHabito tipo;
  final String descripcion;

  /// Realización del día actual, si existe. `null` indica que aún no se marcó
  /// como realizado hoy.
  ///
  /// Para limpiar este campo al eliminar una realización, construí un
  /// [HabitoDeVida] nuevo con `realizacion: null` explícito (no uses
  /// `copyWith`, que no puede vaciar campos opcionales).
  final RealizacionHabito? realizacion;

  const HabitoDeVida({
    required super.id,
    required this.persona,
    required this.tipo,
    required this.descripcion,
    this.realizacion,
  });

  @override
  HabitoDeVida copyWith({
    int? id,
    EntidadBasica? persona,
    TipoHabito? tipo,
    String? descripcion,
    RealizacionHabito? realizacion,
  }) {
    return HabitoDeVida(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      realizacion: realizacion ?? this.realizacion,
    );
  }
}
