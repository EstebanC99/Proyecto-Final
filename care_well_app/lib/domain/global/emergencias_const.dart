/// Parámetros del módulo de Emergencia.
abstract final class EmergenciasConst {
  /// Cantidad de emergencias que trae el historial corto de la pantalla.
  ///
  /// Alcanza para dar contexto ("¿pasó algo hace poco?") sin convertir la
  /// pantalla en un listado. El historial completo, si hace falta, es otra
  /// pantalla y no este bloque.
  static const int cantidadHistorialCorto = 5;
}
