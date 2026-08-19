/// Categorías con las que el backend rotula los registros de la línea de tiempo.
///
/// El valor viaja como texto en `EventoBase.categoriaEvento`, así que hasta acá
/// llega tal cual lo escribe el backend. Se centralizan porque los usan el color
/// de la fila, su rótulo y el filtro: tres lugares donde un typo pasaría
/// desapercibido hasta verlo en pantalla.
abstract final class TimelineCategorias {
  static const String habito = 'Hábito';
  static const String evento = 'Evento';
  static const String animo = 'Ánimo';

  /// Categorías filtrables, en el orden en que se muestran.
  static const List<String> todas = [habito, evento, animo];
}
