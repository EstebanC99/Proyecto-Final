import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import 'demo_seed.dart';

/// Implementación demo (en memoria) de [HealthDatasource].
class DemoHealthDatasource implements HealthDatasource {
  /// Fichas de salud indexadas por persona.id.
  final Map<int, FichaSalud> _fichas = {
    DemoSeed.personaAliciaId: DemoSeed.fichaSaludAlicia,
  };

  final List<HabitoDeVida> _habitos = List.of([
    ...DemoSeed.habitosAlicia,
    ...DemoSeed.habitosMaria,
  ]);
  final List<RecomendacionMedica> _recomendaciones = List.of(
    DemoSeed.recomendacionesAlicia,
  );
  final List<EventoDeSalud> _eventosSalud = List.of([
    ...DemoSeed.eventosSaludAlicia,
    ...DemoSeed.eventosSaludMaria,
  ]);
  final List<EstadoDeAnimo> _estadosAnimo = List.of(
    DemoSeed.estadosAnimoAlicia,
  );
  final List<NotaEvento> _notas = List.of(DemoSeed.notasEvento);

  int _nextId = 10000;

  // ─── Ficha de salud ──────────────────────────────────────────────────────────

  @override
  Future<FichaSalud> getFichaSalud(int personaId) async {
    await Future.delayed(Duration.zero);
    final ficha = _fichas[personaId];
    if (ficha == null) {
      throw Exception('Ficha de salud no encontrada para: $personaId');
    }
    return ficha;
  }

  @override
  Future<FichaSalud> guardarFichaSalud(FichaSalud ficha) async {
    await Future.delayed(Duration.zero);
    final guardada = _fichas.containsKey(ficha.persona.id)
        ? ficha
        : FichaSalud(
            id: _nextId++,
            persona: ficha.persona,
            antecedentes: ficha.antecedentes,
            estudios: ficha.estudios,
          );
    _fichas[ficha.persona.id] = guardada;
    return guardada;
  }

  // ─── Hábitos de vida ─────────────────────────────────────────────────────────

  @override
  Future<List<HabitoDeVida>> getHabitosByPersona(int personaId) async {
    await Future.delayed(Duration.zero);
    return _habitos.where((h) => h.persona.id == personaId).toList();
  }

  @override
  Future<HabitoDeVida> crearHabito(HabitoDeVida habito) async {
    await Future.delayed(Duration.zero);
    final nuevo = HabitoDeVida(
      id: _nextId++,
      persona: habito.persona,
      tipo: habito.tipo,
      descripcion: habito.descripcion,
    );
    _habitos.add(nuevo);
    return nuevo;
  }

  @override
  Future<HabitoDeVida> actualizarHabito(HabitoDeVida habito) async {
    await Future.delayed(Duration.zero);
    final idx = _habitos.indexWhere((h) => h.id == habito.id);
    if (idx < 0) throw Exception('Hábito no encontrado: ${habito.id}');
    _habitos[idx] = habito;
    return habito;
  }

  @override
  Future<void> eliminarHabito(int habitoId) async {
    await Future.delayed(Duration.zero);
    final idx = _habitos.indexWhere((h) => h.id == habitoId);
    if (idx < 0) throw Exception('Hábito no encontrado: $habitoId');
    _habitos.removeAt(idx);
  }

  // ─── Recomendaciones médicas ─────────────────────────────────────────────────

  @override
  Future<List<RecomendacionMedica>> getRecomendacionesByPersona(
    int personaId,
  ) async {
    await Future.delayed(Duration.zero);
    return _recomendaciones.where((r) => r.persona.id == personaId).toList();
  }

  @override
  Future<RecomendacionMedica> crearRecomendacion(
    RecomendacionMedica recomendacion,
  ) async {
    await Future.delayed(Duration.zero);
    final nueva = RecomendacionMedica(
      id: _nextId++,
      persona: recomendacion.persona,
      descripcion: recomendacion.descripcion,
      fecha: recomendacion.fecha,
      profesional: recomendacion.profesional,
    );
    _recomendaciones.add(nueva);
    return nueva;
  }

  @override
  Future<RecomendacionMedica> actualizarRecomendacion(
    RecomendacionMedica recomendacion,
  ) async {
    await Future.delayed(Duration.zero);
    final idx = _recomendaciones.indexWhere((r) => r.id == recomendacion.id);
    if (idx < 0) {
      throw Exception('Recomendación no encontrada: ${recomendacion.id}');
    }
    _recomendaciones[idx] = recomendacion;
    return recomendacion;
  }

  @override
  Future<void> eliminarRecomendacion(int recomendacionId) async {
    await Future.delayed(Duration.zero);
    final idx = _recomendaciones.indexWhere((r) => r.id == recomendacionId);
    if (idx < 0) {
      throw Exception('Recomendación no encontrada: $recomendacionId');
    }
    _recomendaciones.removeAt(idx);
  }

  // ─── Eventos de salud ────────────────────────────────────────────────────────

  @override
  Future<List<EventoDeSalud>> getEventosSaludByPersona(int personaId) async {
    await Future.delayed(Duration.zero);
    return _eventosSalud.where((e) => e.persona.id == personaId).toList();
  }

  @override
  Future<EventoDeSalud> crearEventoSalud(EventoDeSalud evento) async {
    await Future.delayed(Duration.zero);
    final nuevo = EventoDeSalud(
      id: _nextId++,
      persona: evento.persona,
      tipo: evento.tipo,
      fecha: evento.fecha,
      descripcion: evento.descripcion,
    );
    _eventosSalud.add(nuevo);
    return nuevo;
  }

  @override
  Future<EventoDeSalud> actualizarEventoSalud(EventoDeSalud evento) async {
    await Future.delayed(Duration.zero);
    final idx = _eventosSalud.indexWhere((e) => e.id == evento.id);
    if (idx < 0) throw Exception('Evento de salud no encontrado: ${evento.id}');
    _eventosSalud[idx] = evento;
    return evento;
  }

  @override
  Future<void> eliminarEventoSalud(int eventoId) async {
    await Future.delayed(Duration.zero);
    final idx = _eventosSalud.indexWhere((e) => e.id == eventoId);
    if (idx < 0) throw Exception('Evento de salud no encontrado: $eventoId');
    _eventosSalud.removeAt(idx);
    // Eliminar también todas las notas asociadas al evento.
    _notas.removeWhere((n) => n.eventoSaludId == eventoId);
  }

  // ─── Notas de eventos de salud ───────────────────────────────────────────────

  @override
  Future<List<NotaEvento>> getNotasByEvento(int eventoId) async {
    await Future.delayed(Duration.zero);
    return _notas.where((n) => n.eventoSaludId == eventoId).toList();
  }

  @override
  Future<NotaEvento> crearNota(NotaEvento nota) async {
    await Future.delayed(Duration.zero);
    final nueva = NotaEvento(
      id: _nextId++,
      eventoSaludId: nota.eventoSaludId,
      autor: nota.autor,
      fechaHora: nota.fechaHora,
      contenido: nota.contenido,
    );
    _notas.add(nueva);
    return nueva;
  }

  // ─── Estados de ánimo ────────────────────────────────────────────────────────

  @override
  Future<List<EstadoDeAnimo>> getEstadosAnimoByPersona(int personaId) async {
    await Future.delayed(Duration.zero);
    return _estadosAnimo.where((e) => e.persona.id == personaId).toList();
  }

  @override
  Future<EstadoDeAnimo> crearEstadoAnimo(EstadoDeAnimo estadoAnimo) async {
    await Future.delayed(Duration.zero);
    final nuevo = EstadoDeAnimo(
      id: _nextId++,
      persona: estadoAnimo.persona,
      eventoDeSalud: estadoAnimo.eventoDeSalud,
      fecha: estadoAnimo.fecha,
      estado: estadoAnimo.estado,
      observaciones: estadoAnimo.observaciones,
    );
    _estadosAnimo.add(nuevo);
    return nuevo;
  }

  @override
  Future<EstadoDeAnimo> actualizarEstadoAnimo(EstadoDeAnimo estadoAnimo) async {
    await Future.delayed(Duration.zero);
    final idx = _estadosAnimo.indexWhere((e) => e.id == estadoAnimo.id);
    if (idx < 0) {
      throw Exception('Estado de ánimo no encontrado: ${estadoAnimo.id}');
    }
    _estadosAnimo[idx] = estadoAnimo;
    return estadoAnimo;
  }

  @override
  Future<void> eliminarEstadoAnimo(int estadoAnimoId) async {
    await Future.delayed(Duration.zero);
    final idx = _estadosAnimo.indexWhere((e) => e.id == estadoAnimoId);
    if (idx < 0) {
      throw Exception('Estado de ánimo no encontrado: $estadoAnimoId');
    }
    _estadosAnimo.removeAt(idx);
  }
}
