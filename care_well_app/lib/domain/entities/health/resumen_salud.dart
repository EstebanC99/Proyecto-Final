/// Resumen del estado de salud de una persona a cargo, para el hub de Mi salud.
///
/// No extiende `BaseEntity` a propósito: no tiene identidad propia, es un
/// read-model efímero que el backend recalcula en cada consulta (mismo criterio
/// que [AlertaBienestar]). Es inmutable.
///
/// Los campos de ficha son nulos cuando la persona **no tiene ficha cargada**;
/// un cero significa "ficha cargada, sin elementos en esa lista".
class ResumenSalud {
  /// Grupo y factor sanguíneo de la ficha (por ejemplo "0+").
  final String? grupoSanguineo;

  final int? cantidadAlergias;
  final int? cantidadAntecedentes;

  /// Enfermedades **vigentes** de la ficha (el backend excluye las resueltas).
  final int? cantidadEnfermedades;

  /// Hábitos realizados hoy, sobre [cantidadHabitos].
  final int? cantidadHabitosCompletados;

  /// Hábitos activos de la persona.
  final int? cantidadHabitos;

  /// Id del estado de ánimo registrado **hoy** (ver `EstadosAnimoConst`).
  /// Nulo si todavía no se registró ninguno en el día.
  final int? estadoAnimoId;

  /// Descripción del tipo del último evento de salud registrado.
  /// Nulo si la persona no tiene eventos.
  final String? ultimoEventoSalud;

  /// Días transcurridos desde el último evento de salud. Sólo tiene sentido
  /// cuando [ultimoEventoSalud] no es nulo.
  final int? diasDesdeUltimoEvento;

  const ResumenSalud({
    this.grupoSanguineo,
    this.cantidadAlergias,
    this.cantidadAntecedentes,
    this.cantidadEnfermedades,
    this.cantidadHabitosCompletados,
    this.cantidadHabitos,
    this.estadoAnimoId,
    this.ultimoEventoSalud,
    this.diasDesdeUltimoEvento,
  });

  /// `true` si la persona tiene una ficha de salud cargada.
  ///
  /// Se deduce de los recuentos: el backend los devuelve nulos cuando no hay
  /// ficha. No se usa [grupoSanguineo], que puede faltar en una ficha existente.
  bool get tieneFicha =>
      cantidadAlergias != null ||
      cantidadAntecedentes != null ||
      cantidadEnfermedades != null;

  /// `true` si hay al menos un hábito cargado.
  bool get tieneHabitos => (cantidadHabitos ?? 0) > 0;

  /// `true` si hay un evento de salud registrado para mostrar.
  bool get tieneEventos => ultimoEventoSalud != null;
}
