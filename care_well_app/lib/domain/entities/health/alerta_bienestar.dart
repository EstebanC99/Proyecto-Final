/// Observación de bienestar (US-36): alerta heurística automática, no
/// diagnóstica, sobre patrones recientes de ánimo o cumplimiento de hábitos de
/// la persona a cargo.
///
/// No extiende `BaseEntity` a propósito: no tiene identidad propia, es un
/// read-model efímero recalculado por el backend en cada consulta (extender
/// `BaseEntity` sería herencia innecesaria). Es inmutable.
class AlertaBienestar {
  /// Subtipo de la alerta (ver [TiposAlertaBienestar]). Informativo; la UI no
  /// decide el destino de navegación por este campo, sino por [categoria].
  final String tipo;

  /// Severidad reportada por el backend (ver [SeveridadesAlertaBienestar]).
  /// La gradación visual (Atención/Informativa) se deriva de este campo en la
  /// capa de presentación.
  final String severidad;

  /// Categoría de la alerta (ver [CategoriasAlertaBienestar]): define el ícono,
  /// el color de acento y el destino de navegación de la fila.
  final String categoria;

  /// Mensaje ya interpolado por el backend. Se muestra tal cual, sin reprocesar.
  final String mensaje;

  /// Momento de detección de la alerta.
  final DateTime fechaDeteccion;

  /// Identificador del hábito asociado. Presente solo cuando
  /// `categoria == CategoriasAlertaBienestar.habito`.
  final int? habitoVidaId;

  const AlertaBienestar({
    required this.tipo,
    required this.severidad,
    required this.categoria,
    required this.mensaje,
    required this.fechaDeteccion,
    this.habitoVidaId,
  });
}
