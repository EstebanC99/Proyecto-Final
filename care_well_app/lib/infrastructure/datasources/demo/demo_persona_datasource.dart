import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import 'demo_seed.dart';

/// Implementación demo (en memoria) de [PersonaDatasource].
class DemoPersonaDatasource implements PersonaDatasource {
  /// Lista mutable de personas registradas en la sesión demo.
  final List<Persona> _personas = [
    DemoSeed.personaMaria,
    DemoSeed.personaAlicia,
    DemoSeed.personaCarlos,
    DemoSeed.personaLaura,
  ];

  /// Mapa usuarioId → lista de ids de sus dependientes.
  final Map<String, List<String>> _dependientes = {
    DemoSeed.usuarioMariaId: [DemoSeed.personaAliciaId],
  };

  @override
  Future<Persona> getById(String id) async {
    await Future.delayed(Duration.zero);
    final persona = _personas.where((p) => p.id == id).firstOrNull;
    if (persona == null) throw Exception('Persona no encontrada: $id');
    return persona;
  }

  @override
  Future<List<Persona>> getDependientesByUsuario(String usuarioId) async {
    await Future.delayed(Duration.zero);
    final ids = _dependientes[usuarioId] ?? [];
    return _personas.where((p) => ids.contains(p.id)).toList();
  }

  @override
  Future<Persona> crear(Persona persona) async {
    await Future.delayed(Duration.zero);
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final nueva = persona.copyWith(id: 'per_$ts');
    _personas.add(nueva);
    return nueva;
  }

  @override
  Future<Persona> actualizar(Persona persona) async {
    await Future.delayed(Duration.zero);
    final idx = _personas.indexWhere((p) => p.id == persona.id);
    if (idx < 0) throw Exception('Persona no encontrada: ${persona.id}');
    _personas[idx] = persona;
    return persona;
  }

  @override
  Future<void> eliminar(String id) async {
    await Future.delayed(Duration.zero);
    final idx = _personas.indexWhere((p) => p.id == id);
    if (idx < 0) throw Exception('Persona no encontrada: $id');
    _personas.removeAt(idx);
    // Elimina también de los mapas de dependientes.
    for (final entry in _dependientes.entries) {
      entry.value.remove(id);
    }
  }
}
