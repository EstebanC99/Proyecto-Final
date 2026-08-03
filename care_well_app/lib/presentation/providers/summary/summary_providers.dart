import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resumen inteligente (US 9.16) de la persona de contexto.
///
/// Se encadena a [personaVisualizacionSeleccionadaProvider] (mismo patrón que
/// [alertasBienestarProvider]); si no hay persona seleccionada, resuelve a
/// `null`. Es `autoDispose`: se regenera al entrar a la pantalla y al cambiar
/// de persona de contexto.
///
/// El resumen es on-demand y **sin caché**: para forzar una regeneración
/// (botón "Actualizar" o pull-to-refresh) basta con `ref.invalidate` de este
/// provider, que vuelve a pedir al backend.
final resumenInteligenteProvider =
    FutureProvider.autoDispose<ResumenInteligente?>((ref) async {
      final persona = await ref.watch(
        personaVisualizacionSeleccionadaProvider.future,
      );
      if (persona == null) return null;

      return ref
          .watch(summaryRepositoryProvider)
          .obtenerResumen(personaId: persona.id);
    });
