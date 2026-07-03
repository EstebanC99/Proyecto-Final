import '../../domain/datasources/datasources.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

/// Implementación de [AgendaRepository] que delega al [AgendaDatasource] inyectado.
class AgendaRepositoryImpl implements AgendaRepository {
  final AgendaDatasource _datasource;

  const AgendaRepositoryImpl(this._datasource);

  @override
  Future<List<OcurrenciaEventoAgenda>> obtenerOcurrencias({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  }) => _datasource.obtenerOcurrencias(
    personaId: personaId,
    desde: desde,
    hasta: hasta,
  );

  @override
  Future<List<TipoEvento>> obtenerTiposEvento() =>
      _datasource.obtenerTiposEvento();

  @override
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
  }) => _datasource.crearEvento(
    personaId: personaId,
    titulo: titulo,
    descripcion: descripcion,
    tipoEventoId: tipoEventoId,
    fechaHoraInicio: fechaHoraInicio,
    duracionMinutos: duracionMinutos,
    generarEventoSalud: generarEventoSalud,
    minutosAnticipacionRecordatorio: minutosAnticipacionRecordatorio,
    frecuenciaRecurrenciaId: frecuenciaRecurrenciaId,
    intervaloRecurrencia: intervaloRecurrencia,
    fechaFinRecurrencia: fechaFinRecurrencia,
  );

  @override
  Future<void> modificarEvento({
    required int eventoAgendaId,
    required String titulo,
    String? descripcion,
    required int tipoEventoId,
    required DateTime fechaHoraInicio,
    required int duracionMinutos,
    required bool generarEventoSalud,
    int? minutosAnticipacionRecordatorio,
  }) => _datasource.modificarEvento(
    eventoAgendaId: eventoAgendaId,
    titulo: titulo,
    descripcion: descripcion,
    tipoEventoId: tipoEventoId,
    fechaHoraInicio: fechaHoraInicio,
    duracionMinutos: duracionMinutos,
    generarEventoSalud: generarEventoSalud,
    minutosAnticipacionRecordatorio: minutosAnticipacionRecordatorio,
  );

  @override
  Future<void> eliminarEvento(int eventoAgendaId) =>
      _datasource.eliminarEvento(eventoAgendaId);

  @override
  Future<void> cancelarOcurrencia({
    required int eventoAgendaId,
    required DateTime fechaOcurrencia,
  }) => _datasource.cancelarOcurrencia(
    eventoAgendaId: eventoAgendaId,
    fechaOcurrencia: fechaOcurrencia,
  );
}
