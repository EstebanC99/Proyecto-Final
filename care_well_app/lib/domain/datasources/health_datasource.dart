import '../entities/entities.dart';

/// Interfaz de datasource para el módulo Mi Salud.
abstract class HealthDatasource {
  // ─── Ficha de salud ──────────────────────────────────────────────────────────

  /// Retorna la [FichaSalud] de la persona con [personaId].
  /// Lanza excepción si no existe.
  Future<FichaSalud> getFichaSalud(int personaId);

  /// Crea o actualiza la [FichaSalud] de una persona.
  Future<FichaSalud> guardarFichaSalud(FichaSalud ficha);

  // ─── Hábitos de vida ─────────────────────────────────────────────────────────

  /// Retorna los [HabitoDeVida] registrados para la persona con [personaId].
  Future<List<HabitoDeVida>> getHabitosByPersona(int personaId);

  /// Crea un [HabitoDeVida] y retorna la entidad con id generado.
  Future<HabitoDeVida> crearHabito(HabitoDeVida habito);

  /// Actualiza un [HabitoDeVida] existente.
  Future<HabitoDeVida> actualizarHabito(HabitoDeVida habito);

  /// Elimina el [HabitoDeVida] con [habitoId].
  Future<void> eliminarHabito(int habitoId);

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

  // ─── Eventos de salud ────────────────────────────────────────────────────────

  /// Retorna los [EventoDeSalud] de la persona con [personaId].
  Future<List<EventoDeSalud>> getEventosSaludByPersona(int personaId);

  /// Crea un [EventoDeSalud] y retorna la entidad con id generado.
  Future<EventoDeSalud> crearEventoSalud(EventoDeSalud evento);

  /// Actualiza un [EventoDeSalud] existente.
  Future<EventoDeSalud> actualizarEventoSalud(EventoDeSalud evento);

  /// Elimina el [EventoDeSalud] con [eventoId].
  Future<void> eliminarEventoSalud(int eventoId);

  // ─── Notas de eventos de salud ───────────────────────────────────────────────

  /// Retorna las [NotaEvento] del evento con [eventoId].
  Future<List<NotaEvento>> getNotasByEvento(int eventoId);

  /// Crea una [NotaEvento] y retorna la entidad con id generado.
  Future<NotaEvento> crearNota(NotaEvento nota);

  // ─── Estados de ánimo ────────────────────────────────────────────────────────

  /// Retorna los [EstadoDeAnimo] de la persona con [personaId].
  Future<List<EstadoDeAnimo>> getEstadosAnimoByPersona(int personaId);

  /// Crea un [EstadoDeAnimo] y retorna la entidad con id generado.
  Future<EstadoDeAnimo> crearEstadoAnimo(EstadoDeAnimo estadoAnimo);

  /// Actualiza un [EstadoDeAnimo] existente.
  Future<EstadoDeAnimo> actualizarEstadoAnimo(EstadoDeAnimo estadoAnimo);

  /// Elimina el [EstadoDeAnimo] con [estadoAnimoId].
  Future<void> eliminarEstadoAnimo(int estadoAnimoId);
}
