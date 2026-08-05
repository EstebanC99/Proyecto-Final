/// Canal por el que se emite una notificación local.
///
/// El dominio expresa la INTENCIÓN (recordatorio de agenda vs. emergencia); la
/// traducción al `channelId` y a la importancia de Android vive en la
/// implementación de infraestructura.
enum NotificationChannel {
  /// Recordatorios de eventos de agenda.
  agenda,

  /// Alertas de emergencia. Interrumpen al usuario.
  emergencias,
}
