/// Reglas de negocio numéricas compartidas en el frontend.
/// Reflejan constantes del backend (CareWell.Global/RestriccionesNegocio).
abstract final class AppBusinessRules {
  /// Plazo de gracia (en días) durante el cual una asignación eliminada
  /// puede reactivarse antes de su baja definitiva.
  /// Espejo de RestriccionesNegocio.CantidadDiasLimiteParaReactivacionDeAsignacion.
  static const int diasGraciaReactivacion = 30;
}
