import '../entities/entities.dart';

/// Interfaz de datasource para la agenda (eventos y recordatorios).
abstract class AgendaDatasource {
  // ─── Eventos ─────────────────────────────────────────────────────────────────

  /// Retorna todos los [EventoAgenda] de la persona con [personaId].
  Future<List<EventoAgenda>> getEventosByPersona(String personaId);

  /// Retorna los [EventoAgenda] de [personaId] dentro del rango de fechas.
  Future<List<EventoAgenda>> getEventosByRango({
    required String personaId,
    required DateTime desde,
    required DateTime hasta,
  });

  /// Crea un nuevo [EventoAgenda] y retorna la entidad con id generado.
  Future<EventoAgenda> crearEvento(EventoAgenda evento);

  /// Actualiza un [EventoAgenda] existente.
  Future<EventoAgenda> actualizarEvento(EventoAgenda evento);

  /// Elimina el [EventoAgenda] con [eventoId] y sus recordatorios asociados.
  Future<void> eliminarEvento(String eventoId);

  // ─── Recordatorios ───────────────────────────────────────────────────────────

  /// Retorna los [Recordatorio] del evento con [eventoId].
  Future<List<Recordatorio>> getRecordatoriosByEvento(String eventoId);

  /// Crea un [Recordatorio] y retorna la entidad con id generado.
  Future<Recordatorio> crearRecordatorio(Recordatorio recordatorio);

  /// Marca un [Recordatorio] como enviado.
  Future<Recordatorio> marcarEnviado(String recordatorioId);

  /// Elimina el [Recordatorio] con [recordatorioId].
  Future<void> eliminarRecordatorio(String recordatorioId);
}
