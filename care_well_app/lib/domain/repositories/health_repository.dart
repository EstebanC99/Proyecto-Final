import '../entities/entities.dart';

/// Contrato de repositorio para el módulo Mi Salud.
abstract class HealthRepository {
  // ─── Ficha de salud ──────────────────────────────────────────────────────────

  /// Retorna la ficha de salud de la persona con [personaId].
  Future<FichaSalud> getFichaSalud(String personaId);

  /// Crea o actualiza la ficha de salud.
  Future<FichaSalud> guardarFichaSalud(FichaSalud ficha);

  // ─── Hábitos de vida ─────────────────────────────────────────────────────────

  /// Retorna los hábitos registrados para la persona con [personaId].
  Future<List<HabitoDeVida>> getHabitosByPersona(String personaId);

  /// Crea un hábito de vida.
  Future<HabitoDeVida> crearHabito(HabitoDeVida habito);

  /// Actualiza un hábito de vida existente.
  Future<HabitoDeVida> actualizarHabito(HabitoDeVida habito);

  /// Elimina el hábito con [habitoId].
  Future<void> eliminarHabito(String habitoId);

  // ─── Recomendaciones médicas ─────────────────────────────────────────────────

  /// Retorna las recomendaciones médicas de la persona con [personaId].
  Future<List<RecomendacionMedica>> getRecomendacionesByPersona(
    String personaId,
  );

  /// Crea una recomendación médica.
  Future<RecomendacionMedica> crearRecomendacion(
    RecomendacionMedica recomendacion,
  );

  /// Actualiza una recomendación médica existente.
  Future<RecomendacionMedica> actualizarRecomendacion(
    RecomendacionMedica recomendacion,
  );

  /// Elimina la recomendación con [recomendacionId].
  Future<void> eliminarRecomendacion(String recomendacionId);

  // ─── Eventos de salud ────────────────────────────────────────────────────────

  /// Retorna los eventos de salud de la persona con [personaId].
  Future<List<EventoDeSalud>> getEventosSaludByPersona(String personaId);

  /// Crea un evento de salud.
  Future<EventoDeSalud> crearEventoSalud(EventoDeSalud evento);

  /// Actualiza un evento de salud existente.
  Future<EventoDeSalud> actualizarEventoSalud(EventoDeSalud evento);

  /// Elimina el evento de salud con [eventoId].
  Future<void> eliminarEventoSalud(String eventoId);

  // ─── Notas de eventos de salud ───────────────────────────────────────────────

  /// Retorna las notas del evento con [eventoId].
  Future<List<NotaEvento>> getNotasByEvento(String eventoId);

  /// Crea una nota de evento de salud.
  Future<NotaEvento> crearNota(NotaEvento nota);

  // ─── Estados de ánimo ────────────────────────────────────────────────────────

  /// Retorna los estados de ánimo de la persona con [personaId].
  Future<List<EstadoDeAnimo>> getEstadosAnimoByPersona(String personaId);

  /// Crea un estado de ánimo.
  Future<EstadoDeAnimo> crearEstadoAnimo(EstadoDeAnimo estadoAnimo);

  /// Actualiza un estado de ánimo existente.
  Future<EstadoDeAnimo> actualizarEstadoAnimo(EstadoDeAnimo estadoAnimo);

  /// Elimina el estado de ánimo con [estadoAnimoId].
  Future<void> eliminarEstadoAnimo(String estadoAnimoId);
}
