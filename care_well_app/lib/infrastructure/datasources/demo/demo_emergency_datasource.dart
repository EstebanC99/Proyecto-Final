import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import 'demo_seed.dart';

/// Implementación demo (en memoria) de [EmergencyDatasource].
class DemoEmergencyDatasource implements EmergencyDatasource {
  final List<Emergencia> _emergencias = [];

  /// Mapa de personaId → Persona para resolver referencias en demo.
  final Map<int, Persona> _personasById = {
    for (final p in [
      DemoSeed.personaMaria,
      DemoSeed.personaAlicia,
      DemoSeed.personaCarlos,
      DemoSeed.personaLaura,
    ])
      p.id: p,
  };

  int _nextId = 10000;

  @override
  Future<Emergencia> activarEmergencia({
    required int personaId,
    String? descripcion,
  }) async {
    await Future.delayed(Duration.zero);
    final persona = _personasById[personaId];
    if (persona == null) throw Exception('Persona no encontrada: $personaId');
    final emergencia = Emergencia(
      id: _nextId++,
      persona: persona,
      fechaHora: DateTime.now(),
      atendida: false,
      descripcion: descripcion,
    );
    _emergencias.add(emergencia);
    return emergencia;
  }

  @override
  Future<List<Emergencia>> getEmergenciasByPersona(int personaId) async {
    await Future.delayed(Duration.zero);
    return _emergencias.where((e) => e.persona.id == personaId).toList();
  }

  @override
  Future<Emergencia> marcarAtendida(int emergenciaId) async {
    await Future.delayed(Duration.zero);
    final idx = _emergencias.indexWhere((e) => e.id == emergenciaId);
    if (idx < 0) throw Exception('Emergencia no encontrada: $emergenciaId');
    final e = _emergencias[idx];
    final actualizada = Emergencia(
      id: e.id,
      persona: e.persona,
      fechaHora: e.fechaHora,
      atendida: true,
      descripcion: e.descripcion,
    );
    _emergencias[idx] = actualizada;
    return actualizada;
  }
}
