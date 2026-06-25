import '../../domain/datasources/datasources.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

/// Implementación de [AgendaRepository] que delega al [AgendaDatasource] inyectado.
class AgendaRepositoryImpl implements AgendaRepository {
  final AgendaDatasource _datasource;

  const AgendaRepositoryImpl(this._datasource);

  @override
  Future<List<EventoAgenda>> getEventosByPersona(int personaId) =>
      _datasource.getEventosByPersona(personaId);

  @override
  Future<List<EventoAgenda>> getEventosByRango({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  }) => _datasource.getEventosByRango(
    personaId: personaId,
    desde: desde,
    hasta: hasta,
  );

  @override
  Future<EventoAgenda> crearEvento(EventoAgenda evento) =>
      _datasource.crearEvento(evento);

  @override
  Future<EventoAgenda> actualizarEvento(EventoAgenda evento) =>
      _datasource.actualizarEvento(evento);

  @override
  Future<void> eliminarEvento(int eventoId) =>
      _datasource.eliminarEvento(eventoId);

  @override
  Future<List<Recordatorio>> getRecordatoriosByEvento(int eventoId) =>
      _datasource.getRecordatoriosByEvento(eventoId);

  @override
  Future<Recordatorio> crearRecordatorio(Recordatorio recordatorio) =>
      _datasource.crearRecordatorio(recordatorio);

  @override
  Future<Recordatorio> marcarEnviado(int recordatorioId) =>
      _datasource.marcarEnviado(recordatorioId);

  @override
  Future<void> eliminarRecordatorio(int recordatorioId) =>
      _datasource.eliminarRecordatorio(recordatorioId);
}
