/// Evento de salud tal como lo reporta el Resumen inteligente (US 9.16).
///
/// No es [EventoSalud]: acá el evento llega reducido a texto por el backend, sin
/// identidad, tipo ni notas. La [hora] ya viene normalizada a "HH:mm" por el
/// mapper (o `null` si el modelo no la envió o no era interpretable). Es un
/// read-model efímero e inmutable.
class EventoSaludResumen {
  /// Texto del evento listo para mostrar (ej. "Salida para hacer pis").
  final String descripcion;

  /// Hora del evento en formato "HH:mm", o `null` si no se pudo determinar.
  final String? hora;

  /// Hábito o actividad durante la cual ocurrió el evento, si el resumen lo
  /// vinculó (ej. "Durante el paseo matutino"). `null` cuando no hay relación.
  final String? actividadHabitoAsociado;

  const EventoSaludResumen({
    required this.descripcion,
    this.hora,
    this.actividadHabitoAsociado,
  });
}
