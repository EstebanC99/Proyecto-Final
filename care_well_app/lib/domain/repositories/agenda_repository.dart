import '../entities/entities.dart';

/// Contrato de repositorio para la agenda.
abstract class AgendaRepository {
  /// Retorna las ocurrencias de eventos de [personaId] dentro del rango.
  Future<List<OcurrenciaEventoAgenda>> obtenerOcurrencias({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  });

  /// Retorna el catálogo de tipos de evento.
  Future<List<TipoEvento>> obtenerTiposEvento();

  /// Crea un evento de agenda (opcionalmente recurrente).
  Future<void> crearEvento({
    required int personaId,
    required String titulo,
    String? descripcion,
    required int tipoEventoId,
    required DateTime fechaHoraInicio,
    required int duracionMinutos,
    required bool generarEventoSalud,
    int? minutosAnticipacionRecordatorio,
    int? frecuenciaRecurrenciaId,
    int? intervaloRecurrencia,
    DateTime? fechaFinRecurrencia,
  });

  /// Modifica un evento existente (sin alterar su recurrencia).
  Future<void> modificarEvento({
    required int eventoAgendaId,
    required String titulo,
    String? descripcion,
    required int tipoEventoId,
    required DateTime fechaHoraInicio,
    required int duracionMinutos,
    required bool generarEventoSalud,
    int? minutosAnticipacionRecordatorio,
  });

  /// Elimina el evento con [eventoAgendaId].
  Future<void> eliminarEvento(int eventoAgendaId);

  /// Cancela una ocurrencia puntual de un evento recurrente.
  Future<void> cancelarOcurrencia({
    required int eventoAgendaId,
    required DateTime fechaOcurrencia,
  });
}
