import 'package:care_well_app/domain/entities/entities.dart';

abstract class AgendaRepository {
  Future<List<OcurrenciaEventoAgenda>> obtenerOcurrencias({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  });

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

  Future<void> eliminarEvento(int eventoAgendaId);

  Future<void> cancelarOcurrencia({
    required int eventoAgendaId,
    required DateTime fechaOcurrencia,
  });

  /// Elimina la ocurrencia de [fechaOcurrencia] y todas las posteriores de un
  /// evento recurrente; las anteriores se conservan en el historial.
  ///
  /// El backend sólo lo acepta sobre eventos recurrentes y ocurrencias futuras.
  Future<void> cancelarSerieDesde({
    required int eventoAgendaId,
    required DateTime fechaOcurrencia,
  });
}
