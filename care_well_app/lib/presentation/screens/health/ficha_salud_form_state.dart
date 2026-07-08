import '../../../domain/entities/entities.dart';

/// Estado editable (borrador en memoria) del formulario de Ficha de salud.
///
/// Lógica pura, sin dependencias de Flutter ni Riverpod, para ser testeable.
/// La pantalla mantiene una instancia de esta clase en su estado local y la
/// reemplaza con las variantes `copyWith`/mutadoras que retornan estos métodos.
///
/// El borrado de ítems es local y no destructivo: se resuelve recién al
/// construir la [FichaSalud] final en [toFichaSalud], que se persiste una única
/// vez con "Guardar ficha".
class FichaSaludFormState {
  /// Persona a la que pertenece la ficha (contexto, solo lectura).
  final Persona persona;

  /// Id de la ficha existente (0 si es alta).
  final int fichaId;

  /// Factor sanguíneo seleccionado (null si ninguno).
  final String? factorSanguineo;

  /// Obra social (texto libre, opcional).
  final String obraSocial;

  /// Observaciones (texto libre, opcional).
  final String observaciones;

  final List<FichaSaludAntecedente> antecedentes;
  final List<FichaSaludAlergia> alergias;
  final List<FichaSaludEnfermedad> enfermedades;

  const FichaSaludFormState({
    required this.persona,
    this.fichaId = 0,
    this.factorSanguineo,
    this.obraSocial = '',
    this.observaciones = '',
    this.antecedentes = const [],
    this.alergias = const [],
    this.enfermedades = const [],
  });

  /// Estado inicial vacío para una persona sin ficha previa (alta).
  factory FichaSaludFormState.empty(Persona persona) =>
      FichaSaludFormState(persona: persona);

  /// Estado inicial a partir de una ficha existente (edición).
  factory FichaSaludFormState.fromFicha(FichaSalud ficha) {
    return FichaSaludFormState(
      persona: ficha.persona,
      fichaId: ficha.id,
      factorSanguineo: ficha.factorSanguineo.isEmpty
          ? null
          : ficha.factorSanguineo,
      obraSocial: ficha.obraSocial ?? '',
      observaciones: ficha.observaciones ?? '',
      antecedentes: List.of(ficha.antecedentes),
      alergias: List.of(ficha.alergias),
      enfermedades: List.of(ficha.enfermedades),
    );
  }

  /// `true` si la ficha puede guardarse (factor sanguíneo obligatorio).
  bool get canSave =>
      factorSanguineo != null && factorSanguineo!.trim().isNotEmpty;

  FichaSaludFormState copyWith({
    String? factorSanguineo,
    String? obraSocial,
    String? observaciones,
    List<FichaSaludAntecedente>? antecedentes,
    List<FichaSaludAlergia>? alergias,
    List<FichaSaludEnfermedad>? enfermedades,
  }) {
    return FichaSaludFormState(
      persona: persona,
      fichaId: fichaId,
      factorSanguineo: factorSanguineo ?? this.factorSanguineo,
      obraSocial: obraSocial ?? this.obraSocial,
      observaciones: observaciones ?? this.observaciones,
      antecedentes: antecedentes ?? this.antecedentes,
      alergias: alergias ?? this.alergias,
      enfermedades: enfermedades ?? this.enfermedades,
    );
  }

  // ─── Antecedentes ────────────────────────────────────────────────────────────

  FichaSaludFormState agregarAntecedente(FichaSaludAntecedente item) =>
      copyWith(antecedentes: [...antecedentes, item]);

  FichaSaludFormState actualizarAntecedente(
    int index,
    FichaSaludAntecedente item,
  ) {
    final lista = List.of(antecedentes)..[index] = item;
    return copyWith(antecedentes: lista);
  }

  FichaSaludFormState quitarAntecedente(int index) {
    final lista = List.of(antecedentes)..removeAt(index);
    return copyWith(antecedentes: lista);
  }

  FichaSaludFormState insertarAntecedente(
    int index,
    FichaSaludAntecedente item,
  ) {
    final lista = List.of(antecedentes)
      ..insert(index.clamp(0, antecedentes.length), item);
    return copyWith(antecedentes: lista);
  }

  // ─── Alergias ─────────────────────────────────────────────────────────────────

  FichaSaludFormState agregarAlergia(FichaSaludAlergia item) =>
      copyWith(alergias: [...alergias, item]);

  FichaSaludFormState actualizarAlergia(int index, FichaSaludAlergia item) {
    final lista = List.of(alergias)..[index] = item;
    return copyWith(alergias: lista);
  }

  FichaSaludFormState quitarAlergia(int index) {
    final lista = List.of(alergias)..removeAt(index);
    return copyWith(alergias: lista);
  }

  FichaSaludFormState insertarAlergia(int index, FichaSaludAlergia item) {
    final lista = List.of(alergias)
      ..insert(index.clamp(0, alergias.length), item);
    return copyWith(alergias: lista);
  }

  // ─── Enfermedades ──────────────────────────────────────────────────────────────

  FichaSaludFormState agregarEnfermedad(FichaSaludEnfermedad item) =>
      copyWith(enfermedades: [...enfermedades, item]);

  FichaSaludFormState actualizarEnfermedad(
    int index,
    FichaSaludEnfermedad item,
  ) {
    final lista = List.of(enfermedades)..[index] = item;
    return copyWith(enfermedades: lista);
  }

  FichaSaludFormState quitarEnfermedad(int index) {
    final lista = List.of(enfermedades)..removeAt(index);
    return copyWith(enfermedades: lista);
  }

  FichaSaludFormState insertarEnfermedad(int index, FichaSaludEnfermedad item) {
    final lista = List.of(enfermedades)
      ..insert(index.clamp(0, enfermedades.length), item);
    return copyWith(enfermedades: lista);
  }

  // ─── Conversión a entidad de dominio ────────────────────────────────────────────

  /// Construye la [FichaSalud] a persistir a partir del borrador actual.
  ///
  /// Requiere que [canSave] sea `true` (factor sanguíneo presente).
  FichaSalud toFichaSalud() {
    final obra = obraSocial.trim();
    final obs = observaciones.trim();
    return FichaSalud(
      id: fichaId,
      persona: persona,
      factorSanguineo: factorSanguineo!.trim(),
      obraSocial: obra.isEmpty ? null : obra,
      observaciones: obs.isEmpty ? null : obs,
      antecedentes: List.of(antecedentes),
      alergias: List.of(alergias),
      enfermedades: List.of(enfermedades),
    );
  }
}
