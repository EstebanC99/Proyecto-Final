import '../entities/entities.dart';

/// Contrato de repositorio para la agenda (eventos y recordatorios).
abstract class AgendaRepository {
  // ─── Eventos ─────────────────────────────────────────────────────────────────

  /// Retorna todos los eventos de la persona con [personaId].
  Future<List<EventoAgenda>> getEventosByPersona(int personaId);

  /// Retorna los eventos de [personaId] dentro del rango de fechas indicado.
  Future<List<EventoAgenda>> getEventosByRango({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  });

  /// Crea un nuevo evento de agenda.
  Future<EventoAgenda> crearEvento(EventoAgenda evento);

  /// Actualiza un evento existente.
  Future<EventoAgenda> actualizarEvento(EventoAgenda evento);

  /// Elimina el evento con [eventoId] y sus recordatorios.
  Future<void> eliminarEvento(int eventoId);

  // ─── Recordatorios ───────────────────────────────────────────────────────────

  /// Retorna los recordatorios del evento con [eventoId].
  Future<List<Recordatorio>> getRecordatoriosByEvento(int eventoId);

  /// Crea un nuevo recordatorio.
  Future<Recordatorio> crearRecordatorio(Recordatorio recordatorio);

  /// Marca el recordatorio con [recordatorioId] como enviado.
  Future<Recordatorio> marcarEnviado(int recordatorioId);

  /// Elimina el recordatorio con [recordatorioId].
  Future<void> eliminarRecordatorio(int recordatorioId);
}
