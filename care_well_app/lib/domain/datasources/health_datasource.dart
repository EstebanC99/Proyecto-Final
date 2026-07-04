import '../entities/entities.dart';

/// Interfaz de datasource para el módulo Mi Salud.
abstract class HealthDatasource {
  // ─── Ficha de salud ──────────────────────────────────────────────────────────

  /// Retorna la [FichaSalud] de la persona con [personaId].
  /// Lanza excepción si no existe.
  Future<FichaSalud> getFichaSalud(int personaId);

  /// Crea o actualiza la [FichaSalud] de una persona.
  Future<FichaSalud> guardarFichaSalud(FichaSalud ficha);

  // ─── Recomendaciones médicas ─────────────────────────────────────────────────

  /// Retorna las [RecomendacionMedica] de la persona con [personaId].
  Future<List<RecomendacionMedica>> getRecomendacionesByPersona(int personaId);

  /// Crea una [RecomendacionMedica] y retorna la entidad con id generado.
  Future<RecomendacionMedica> crearRecomendacion(
    RecomendacionMedica recomendacion,
  );

  /// Actualiza una [RecomendacionMedica] existente.
  Future<RecomendacionMedica> actualizarRecomendacion(
    RecomendacionMedica recomendacion,
  );

  /// Elimina la [RecomendacionMedica] con [recomendacionId].
  Future<void> eliminarRecomendacion(int recomendacionId);
}
