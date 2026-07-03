import '../entities/entities.dart';

/// Contrato de repositorio para el módulo Mi Salud.
abstract class HealthRepository {
  // ─── Ficha de salud ──────────────────────────────────────────────────────────

  /// Retorna la ficha de salud de la persona con [personaId].
  Future<FichaSalud> getFichaSalud(int personaId);

  /// Crea o actualiza la ficha de salud.
  Future<FichaSalud> guardarFichaSalud(FichaSalud ficha);

  // ─── Hábitos de vida ─────────────────────────────────────────────────────────

  /// Retorna los hábitos registrados para la persona con [personaId].
  Future<List<HabitoDeVida>> getHabitosByPersona(int personaId);

  /// Crea un hábito de vida.
  Future<HabitoDeVida> crearHabito(HabitoDeVida habito);

  /// Actualiza un hábito de vida existente.
  Future<HabitoDeVida> actualizarHabito(HabitoDeVida habito);

  /// Elimina el hábito con [habitoId].
  Future<void> eliminarHabito(int habitoId);

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

  // ─── Estados de ánimo ────────────────────────────────────────────────────────

  /// Retorna los estados de ánimo de la persona con [personaId].
  Future<List<EstadoDeAnimo>> getEstadosAnimoByPersona(int personaId);

  /// Crea un estado de ánimo.
  Future<EstadoDeAnimo> crearEstadoAnimo(EstadoDeAnimo estadoAnimo);

  /// Actualiza un estado de ánimo existente.
  Future<EstadoDeAnimo> actualizarEstadoAnimo(EstadoDeAnimo estadoAnimo);

  /// Elimina el estado de ánimo con [estadoAnimoId].
  Future<void> eliminarEstadoAnimo(int estadoAnimoId);
}
