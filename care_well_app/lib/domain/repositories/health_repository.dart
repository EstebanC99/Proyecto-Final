import 'package:care_well_app/domain/entities/entities.dart';

/// Contrato de repositorio para el módulo Mi Salud.
abstract class HealthRepository {
  // ─── Ficha de salud ──────────────────────────────────────────────────────────

  /// Retorna la ficha de salud de la persona con [personaId].
  Future<FichaSalud> getFichaSalud(int personaId);

  /// Crea o actualiza la ficha de salud.
  Future<FichaSalud> guardarFichaSalud(FichaSalud ficha);

  // ─── Recomendaciones médicas ─────────────────────────────────────────────────

  /// Retorna las recomendaciones médicas de la persona con [personaId].
  Future<List<RecomendacionMedica>> getRecomendacionesByPersona(int personaId);

  /// Crea una recomendación médica.
  Future<RecomendacionMedica> crearRecomendacion(
    RecomendacionMedica recomendacion,
  );

  /// Actualiza una recomendación médica existente.
  Future<RecomendacionMedica> actualizarRecomendacion(
    RecomendacionMedica recomendacion,
  );

  /// Elimina la recomendación con [recomendacionId].
  Future<void> eliminarRecomendacion(int recomendacionId);
}
