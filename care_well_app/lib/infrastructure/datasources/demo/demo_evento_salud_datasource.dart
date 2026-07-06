import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import 'demo_seed.dart';

/// Implementación demo (en memoria) de [EventoSaludDatasource].
///
/// Mantiene los eventos de salud con sus notas embebidas. Los mutadores
/// modifican la lista en memoria (no hay persistencia entre reinicios).
class DemoEventoSaludDatasource implements EventoSaludDatasource {
  final List<EventoSalud> _eventos = List.of([
    ...DemoSeed.eventosSaludAlicia,
    ...DemoSeed.eventosSaludMaria,
  ]);

  int _nextEventoId = 20000;
  int _nextNotaId = 21000;

  /// Descripción de tipo de evento a partir de su id (catálogo de agenda).
  static const Map<int, String> _descripcionTipo = {
    TiposEventoAgendaConst.citaMedica: 'Cita médica',
    TiposEventoAgendaConst.medicacion: 'Medicación',
    TiposEventoAgendaConst.rehabilitacion: 'Rehabilitación',
    TiposEventoAgendaConst.control: 'Control',
    TiposEventoAgendaConst.hospitalizacion: 'Hospitalización',
    TiposEventoAgendaConst.cirugia: 'Cirugía',
    TiposEventoAgendaConst.tratamiento: 'Tratamiento',
    TiposEventoAgendaConst.bienestar: 'Bienestar',
    TiposEventoAgendaConst.sintoma: 'Síntoma',
    TiposEventoAgendaConst.diagnostico: 'Diagnóstico',
    TiposEventoAgendaConst.vacuna: 'Vacuna',
    TiposEventoAgendaConst.actividadFisica: 'Actividad física',
    TiposEventoAgendaConst.otro: 'Otro',
  };

  /// Autor demo de las notas (el usuario logueado en la demo es María).
  static final EntidadBasica _autorDemo = EntidadBasica(
    id: DemoSeed.personaMariaId,
    descripcion: 'María García',
  );

  @override
  Future<List<EventoSalud>> getEventosSaludDelMes({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    await Future.delayed(Duration.zero);
    return _eventos
        .where(
          (e) =>
              e.persona.id == personaId &&
              !e.fechaHora.isBefore(desde) &&
              e.fechaHora.isBefore(hasta),
        )
        .toList();
  }

  @override
  Future<void> crearEventoSalud({
    required int personaId,
    required int tipoId,
    required DateTime fechaHora,
    required String descripcion,
  }) async {
    await Future.delayed(Duration.zero);
    _eventos.add(
      EventoSalud(
        id: _nextEventoId++,
        persona: EntidadBasica(
          id: personaId,
          descripcion: _descripcionPersona(personaId),
        ),
        tipo: TipoEventoSalud(
          id: tipoId,
          descripcion: _descripcionTipo[tipoId] ?? 'Otro',
        ),
        fechaHora: fechaHora,
        descripcion: descripcion,
      ),
    );
  }

  @override
  Future<void> eliminarEventoSalud(int eventoId) async {
    await Future.delayed(Duration.zero);
    _eventos.removeWhere((e) => e.id == eventoId);
  }

  @override
  Future<void> agregarNota({
    required int eventoSaludId,
    required String contenido,
  }) async {
    await Future.delayed(Duration.zero);
    final idx = _indexEvento(eventoSaludId);
    final evento = _eventos[idx];
    final nota = NotaEventoSalud(
      id: _nextNotaId++,
      eventoSaludId: eventoSaludId,
      autor: _autorDemo,
      fechaHora: DateTime.now(),
      contenido: contenido,
    );
    _eventos[idx] = evento.copyWith(notas: [...evento.notas, nota]);
  }

  @override
  Future<void> modificarNota({
    required int eventoSaludId,
    required int notaId,
    required String contenido,
  }) async {
    await Future.delayed(Duration.zero);
    final idx = _indexEvento(eventoSaludId);
    final evento = _eventos[idx];
    final notas = evento.notas
        .map((n) => n.id == notaId ? n.copyWith(contenido: contenido) : n)
        .toList();
    _eventos[idx] = evento.copyWith(notas: notas);
  }

  @override
  Future<void> eliminarNota({
    required int eventoSaludId,
    required int notaId,
  }) async {
    await Future.delayed(Duration.zero);
    final idx = _indexEvento(eventoSaludId);
    final evento = _eventos[idx];
    final notas = evento.notas.where((n) => n.id != notaId).toList();
    _eventos[idx] = evento.copyWith(notas: notas);
  }

  int _indexEvento(int eventoId) {
    final idx = _eventos.indexWhere((e) => e.id == eventoId);
    if (idx < 0) throw Exception('Evento de salud no encontrado: $eventoId');
    return idx;
  }

  String _descripcionPersona(int personaId) => switch (personaId) {
    DemoSeed.personaAliciaId => 'Alicia Rodríguez',
    DemoSeed.personaMariaId => 'María García',
    DemoSeed.personaCarlosId => 'Carlos Pérez',
    DemoSeed.personaLauraId => 'Laura Méndez',
    DemoSeed.personaRobertoId => 'Roberto Sánchez',
    _ => '',
  };
}
