/// Mensaje push recibido desde el servicio de mensajería, ya despegado del SDK.
///
/// Permite que `presentation` reaccione a las notificaciones sin conocer
/// `firebase_messaging`: la traducción del mensaje del proveedor a esta clase
/// vive en `infrastructure/notifications`.
class PushMessage {
  /// Título mostrado por el sistema. Nulo en mensajes data-only.
  final String? titulo;

  /// Cuerpo mostrado por el sistema. Nulo en mensajes data-only.
  final String? cuerpo;

  /// Payload de datos. FCM siempre entrega los valores como texto.
  final Map<String, String> datos;

  const PushMessage({this.titulo, this.cuerpo, this.datos = const {}});

  /// Discriminador del tipo de aviso (p. ej. `EMERGENCIA`).
  String? get tipo => datos['tipo'];

  /// Persona de contexto del aviso, si el payload la incluye.
  int? get personaId => int.tryParse(datos['personaId'] ?? '');

  /// Emergencia que originó el aviso, si el payload la incluye.
  int? get emergenciaId => int.tryParse(datos['emergenciaId'] ?? '');
}
