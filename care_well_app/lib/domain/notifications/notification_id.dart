/// Derivación de identificadores estables de notificación a partir de datos de
/// dominio.
///
/// Vive en `domain` para que `presentation` no dependa de la implementación de
/// infraestructura (`LocalNotificationScheduler`), respetando la regla
/// `presentation → domain ← infrastructure`.
abstract final class NotificationId {
  /// Deriva un id de notificación estable a partir del evento base y la fecha
  /// de la ocurrencia, de modo que cada ocurrencia recurrente tenga un id único.
  ///
  /// Se aplica `& 0x7fffffff` para garantizar un valor positivo de 32 bits,
  /// compatible con la API de notificaciones de Android.
  static int forOcurrencia(int eventoAgendaId, DateTime fechaOcurrencia) {
    return (eventoAgendaId * 100000 +
            fechaOcurrencia.millisecondsSinceEpoch ~/
                (1000 * 60 * 60 * 24) %
                100000) &
        0x7fffffff;
  }
}
