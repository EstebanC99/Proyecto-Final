import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import 'demo_seed.dart';

/// Implementación demo (en memoria) de [HealthDatasource].
///
/// Solo gestiona ficha de salud y recomendaciones médicas. Los hábitos de vida
/// y los estados de ánimo se gestionan vía sus datasources API (siempre API,
/// sin demo).
class DemoHealthDatasource implements HealthDatasource {
  /// Fichas de salud indexadas por persona.id.
  final Map<int, FichaSalud> _fichas = {
    DemoSeed.personaAliciaId: DemoSeed.fichaSaludAlicia,
  };

  final List<RecomendacionMedica> _recomendaciones = List.of(
    DemoSeed.recomendacionesAlicia,
  );

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
}
