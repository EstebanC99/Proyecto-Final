/// Catálogos cerrados del módulo Mi salud usados en el frontend.
///
/// Reflejan valores de referencia del dominio. Al integrar la API estos
/// catálogos podrían provenir del backend; por ahora son constantes locales.
abstract final class FactoresSanguineos {
  /// Valores posibles de factor sanguíneo (grupo ABO + factor Rh).
  ///
  /// Orden fijo para el selector tipo grilla (4×2) de la Ficha de salud.
  static const List<String> valores = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
}
