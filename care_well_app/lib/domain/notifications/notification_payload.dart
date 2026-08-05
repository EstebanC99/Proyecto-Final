/// Payload de una notificación local, con su tipo explícito.
///
/// Se serializa como `"<tipo>:<id>"`. El tipo es obligatorio: un id suelto no
/// permite saber a qué feature pertenece y hace ambiguo el destino del deep
/// link (un `"12"` podría ser tanto una persona como un evento de agenda).
///
/// El [tipo] usa el mismo vocabulario que el `data.tipo` de las notificaciones
/// push (`TiposPushConst`), para no tener dos discriminadores en paralelo.
class NotificationPayload {
  final String tipo;
  final int id;

  const NotificationPayload({required this.tipo, required this.id});

  String encode() => '$tipo:$id';

  /// Devuelve `null` si el texto no tiene el formato esperado.
  ///
  /// Es tolerante a propósito: el payload puede venir de una notificación
  /// vieja o de otra versión de la app, y eso no debe romper nada.
  static NotificationPayload? decode(String? raw) {
    if (raw == null) return null;

    final separador = raw.indexOf(':');
    if (separador <= 0) return null;

    final id = int.tryParse(raw.substring(separador + 1));
    if (id == null) return null;

    return NotificationPayload(tipo: raw.substring(0, separador), id: id);
  }
}
