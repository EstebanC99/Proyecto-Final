/// Hábito de vida tal como lo reporta el Resumen inteligente (US 9.16).
///
/// No es [HabitoVida]: acá el hábito llega ya resumido por el backend, sin
/// identidad ni tipo, apenas con la descripción que se muestra y si quedó
/// registrado como realizado en el día. Es un read-model efímero e inmutable.
class HabitoResumen {
  /// Texto del hábito listo para mostrar (ej. "Paseo matutino").
  final String descripcion;

  /// `true` cuando el hábito ya se registró como realizado.
  final bool completado;

  const HabitoResumen({required this.descripcion, required this.completado});
}
