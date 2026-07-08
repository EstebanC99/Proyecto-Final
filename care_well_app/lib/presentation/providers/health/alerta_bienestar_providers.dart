import 'package:care_well_app/config/constraints/wellbeing_alert_catalogs.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Observaciones de bienestar (US-36) de la persona de contexto.
///
/// Se encadena a [personaVisualizacionSeleccionadaProvider] (mismo patrón que
/// [fichaSaludProvider]); si no hay persona seleccionada, resuelve a lista
/// vacía. Es `autoDispose`: se recalcula al cambiar de persona o al salir del
/// hub.
final alertasBienestarProvider =
    FutureProvider.autoDispose<List<AlertaBienestar>>((ref) async {
      final persona = await ref.watch(
        personaVisualizacionSeleccionadaProvider.future,
      );
      if (persona == null) return const [];

      return ref
          .watch(alertaBienestarRepositoryProvider)
          .getAlertasBienestar(persona);
    });

/// Observaciones de bienestar ordenadas para presentación: las de severidad
/// `alta` (nivel visual "Atención") primero, preservando el orden relativo que
/// entregó el backend dentro de cada grupo de severidad.
///
/// El ordenamiento es **estable**: como `List.sort` de Dart no garantiza
/// estabilidad, se ordena por una clave compuesta `(grupoSeveridad, índice
/// original)`, de modo que empates dentro del mismo grupo conservan el orden de
/// llegada.
final alertasBienestarOrdenadasProvider =
    Provider.autoDispose<AsyncValue<List<AlertaBienestar>>>((ref) {
      final async = ref.watch(alertasBienestarProvider);

      return async.whenData((alertas) {
        final indexadas = alertas.indexed.toList()
          ..sort((a, b) {
            final grupoA = _grupoSeveridad(a.$2.severidad);
            final grupoB = _grupoSeveridad(b.$2.severidad);
            if (grupoA != grupoB) return grupoA.compareTo(grupoB);
            // Empate de grupo: preserva el orden original (estabilidad).
            return a.$1.compareTo(b.$1);
          });

        return indexadas.map((e) => e.$2).toList();
      });
    });

/// Grupo de orden por severidad: `alta` (0) antes que el resto (1).
int _grupoSeveridad(String severidad) =>
    severidad == SeveridadesAlertaBienestar.alta ? 0 : 1;
