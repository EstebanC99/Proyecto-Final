/// Resumen inteligente de la persona a cargo (US 9.16): bloque narrativo en
/// lenguaje natural, redactado por un componente de IA generativa a partir de
/// los eventos de salud, hábitos de vida y estados de ánimo del día.
///
/// No extiende `BaseEntity` a propósito (mismo criterio que [AlertaBienestar]):
/// es un read-model **efímero**, generado on-demand y **no persistido**. No
/// tiene identidad propia. Es inmutable.
class ResumenInteligente {
  /// Texto narrativo ya redactado por el backend. Se muestra tal cual, sin
  /// reprocesar. Es `null` cuando no hay datos para resumir ([tieneDatos] es
  /// `false`): en ese caso el backend no invoca a la IA.
  final String? texto;

  /// Indica si hubo información en alguno de los tres orígenes para el día.
  /// Cuando es `false`, la UI muestra el estado vacío en lugar de la narrativa.
  final bool tieneDatos;

  /// Momento en que se generó el resumen (lo fija el backend en cada consulta).
  final DateTime generadoEn;

  const ResumenInteligente({
    required this.texto,
    required this.tieneDatos,
    required this.generadoEn,
  });
}
