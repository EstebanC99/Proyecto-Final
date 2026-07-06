import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//region Acciones de Consulta
final estadosAnimoProvider = FutureProvider<List<PersonaEstadoAnimo>>((
  ref,
) async {
  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return [];
  final ahora = DateTime.now();
  final desde = DateTime(ahora.year, ahora.month, 1);
  final hasta = DateTime(ahora.year, ahora.month + 1, 1);
  final estados = await ref
      .watch(estadoAnimoRepositoryProvider)
      .obtenerPorFechas(persona: persona, desde: desde, hasta: hasta);
  return estados..sort((a, b) => b.fecha.compareTo(a.fecha));
});

final animoHoyProvider = FutureProvider<PersonaEstadoAnimo?>((ref) async {
  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return null;
  return ref.watch(estadoAnimoRepositoryProvider).obtenerAnimoHoy(persona);
});

//endregion

//region Acciones Mutadoras

final registrarAnimoProvider =
    Provider<
      Future<void> Function({required int estadoAnimoId, String? observaciones})
    >((ref) {
      return ({required estadoAnimoId, observaciones}) async {
        final persona = await ref.read(healthPersonaContextProvider.future);
        if (persona == null) throw Exception('No hay persona de contexto');

        await ref
            .read(estadoAnimoRepositoryProvider)
            .registrar(
              personaId: persona.id,
              estadoAnimoId: estadoAnimoId,
              observaciones: observaciones,
            );
        ref.invalidate(animoHoyProvider);
        ref.invalidate(estadosAnimoProvider);
      };
    });

//endregion
