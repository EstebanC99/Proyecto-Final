/// Frecuencia de recurrencia de un evento de agenda.
enum FrecuenciaRecurrencia {
  diaria,
  semanal,
  mensual;

  /// Identificador persistido en el backend.
  int get id => switch (this) {
    FrecuenciaRecurrencia.diaria => 1,
    FrecuenciaRecurrencia.semanal => 2,
    FrecuenciaRecurrencia.mensual => 3,
  };

  static FrecuenciaRecurrencia fromId(int id) => switch (id) {
    1 => FrecuenciaRecurrencia.diaria,
    2 => FrecuenciaRecurrencia.semanal,
    3 => FrecuenciaRecurrencia.mensual,
    _ => throw ArgumentError('FrecuenciaRecurrencia desconocida: $id'),
  };
}
