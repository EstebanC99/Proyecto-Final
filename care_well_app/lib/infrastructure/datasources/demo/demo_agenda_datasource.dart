import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import 'demo_seed.dart';

/// Implementación demo (en memoria) de [AgendaDatasource].
class DemoAgendaDatasource implements AgendaDatasource {
  final List<EventoAgenda> _eventos = List.of(DemoSeed.eventosAgenda);
  final List<Recordatorio> _recordatorios = List.of(
    DemoSeed.recordatoriosAgenda,
  );

  int _nextId = 10000;

  // ─── Eventos ─────────────────────────────────────────────────────────────────

  @override
  Future<List<EventoAgenda>> getEventosByPersona(int personaId) async {
    await Future.delayed(Duration.zero);
    return _eventos.where((e) => e.persona.id == personaId).toList();
  }

  @override
  Future<List<EventoAgenda>> getEventosByRango({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    await Future.delayed(Duration.zero);
    return _eventos
        .where(
          (e) =>
              e.persona.id == personaId &&
              !e.fechaHoraInicio.isBefore(desde) &&
              !e.fechaHoraInicio.isAfter(hasta),
        )
        .toList();
  }

  @override
  Future<EventoAgenda> crearEvento(EventoAgenda evento) async {
    await Future.delayed(Duration.zero);
    final nuevo = EventoAgenda(
      id: _nextId++,
      persona: evento.persona,
      creadoPor: evento.creadoPor,
      titulo: evento.titulo,
      descripcion: evento.descripcion,
      tipo: evento.tipo,
      fechaHoraInicio: evento.fechaHoraInicio,
      fechaHoraFin: evento.fechaHoraFin,
    );
    _eventos.add(nuevo);
    return nuevo;
  }

  @override
  Future<EventoAgenda> actualizarEvento(EventoAgenda evento) async {
    await Future.delayed(Duration.zero);
    final idx = _eventos.indexWhere((e) => e.id == evento.id);
    if (idx < 0) throw Exception('Evento no encontrado: ${evento.id}');
    _eventos[idx] = evento;
    return evento;
  }

  @override
  Future<void> eliminarEvento(int eventoId) async {
    await Future.delayed(Duration.zero);
    final idx = _eventos.indexWhere((e) => e.id == eventoId);
    if (idx < 0) throw Exception('Evento no encontrado: $eventoId');
    _eventos.removeAt(idx);
    _recordatorios.removeWhere((r) => r.eventoAgenda.id == eventoId);
  }

  // ─── Recordatorios ───────────────────────────────────────────────────────────

  @override
  Future<List<Recordatorio>> getRecordatoriosByEvento(int eventoId) async {
    await Future.delayed(Duration.zero);
    return _recordatorios.where((r) => r.eventoAgenda.id == eventoId).toList();
  }

  @override
  Future<Recordatorio> crearRecordatorio(Recordatorio recordatorio) async {
    await Future.delayed(Duration.zero);
    final nuevo = Recordatorio(
      id: _nextId++,
      eventoAgenda: recordatorio.eventoAgenda,
      fechaHoraEnvio: recordatorio.fechaHoraEnvio,
      enviado: false,
    );
    _recordatorios.add(nuevo);
    return nuevo;
  }

  @override
  Future<Recordatorio> marcarEnviado(int recordatorioId) async {
    await Future.delayed(Duration.zero);
    final idx = _recordatorios.indexWhere((r) => r.id == recordatorioId);
    if (idx < 0) {
      throw Exception('Recordatorio no encontrado: $recordatorioId');
    }
    final r = _recordatorios[idx];
    final actualizado = Recordatorio(
      id: r.id,
      eventoAgenda: r.eventoAgenda,
      fechaHoraEnvio: r.fechaHoraEnvio,
      enviado: true,
    );
    _recordatorios[idx] = actualizado;
    return actualizado;
  }

  @override
  Future<void> eliminarRecordatorio(int recordatorioId) async {
    await Future.delayed(Duration.zero);
    final idx = _recordatorios.indexWhere((r) => r.id == recordatorioId);
    if (idx < 0) {
      throw Exception('Recordatorio no encontrado: $recordatorioId');
    }
    _recordatorios.removeAt(idx);
  }
}
