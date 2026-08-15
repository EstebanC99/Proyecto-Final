import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resumen inteligente (US 9.16) de la persona de contexto.
///
/// El backend cachea el resumen por persona (mismo día, menos de 3 h): la
/// carga normal reutiliza el último vigente —y devuelve su hora de generación
/// original— y sólo [SummaryNotifier.refrescar] pide una regeneración real
/// contra el modelo de IA.
///
/// Se encadena a [personaVisualizacionSeleccionadaProvider]: si no hay persona
/// seleccionada resuelve a `null`. Es `autoDispose`.
class SummaryNotifier extends AsyncNotifier<ResumenInteligente?> {
  /// Carga normal: al montar la primera pantalla que lo observa y cada vez que
  /// cambia la persona de contexto. No fuerza la regeneración.
  @override
  Future<ResumenInteligente?> build() async {
    final persona = await ref.watch(
      personaVisualizacionSeleccionadaProvider.future,
    );
    return _obtener(persona, forzarActualizacion: false);
  }

  /// Regeneración explícita: botón "Actualizar" y pull-to-refresh de `/summary`.
  ///
  /// La persona se toma con `ref.read`: la suscripción reactiva ya la creó
  /// [build], que se vuelve a ejecutar sola si cambia el contexto.
  Future<void> refrescar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final persona = await ref.read(
        personaVisualizacionSeleccionadaProvider.future,
      );
      return _obtener(persona, forzarActualizacion: true);
    });
  }

  Future<ResumenInteligente?> _obtener(
    Persona? persona, {
    required bool forzarActualizacion,
  }) async {
    if (persona == null) return null;

    return ref
        .read(summaryRepositoryProvider)
        .obtenerResumen(
          personaId: persona.id,
          forzarActualizacion: forzarActualizacion,
        );
  }
}

/// Provider del resumen inteligente de la persona de contexto.
///
/// Lo consumen el Home (card hero) y la pantalla `/summary`, y tiene que ser
/// la misma instancia: la generación puede tardar decenas de segundos y dos
/// providers distintos dispararían dos inferencias en paralelo para la misma
/// persona (perdiendo además una de las dos escrituras del backend).
final resumenInteligenteProvider =
    AsyncNotifierProvider.autoDispose<SummaryNotifier, ResumenInteligente?>(
      SummaryNotifier.new,
      // Sin reintento automático (Riverpod reintenta hasta 10 veces con
      // backoff por defecto): cada reintento puede costar una inferencia de IA
      // y, mientras tanto, la UI se queda en "Generando…" casi un minuto sin
      // informar la falla. Acá el reintento es explícito y lo decide el
      // usuario ("Reintentar" en el Home, "Actualizar" en /summary), igual que
      // en [SummaryNotifier.refrescar], que tampoco reintenta.
      retry: (retryCount, error) => null,
    );
