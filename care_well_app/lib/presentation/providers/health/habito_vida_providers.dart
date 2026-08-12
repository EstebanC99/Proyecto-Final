import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//region Acciones de Consulta

final habitosProvider = FutureProvider<List<HabitoVida>>((ref) async {
  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return [];
  return ref
      .watch(habitoVidaRepositoryProvider)
      .getHabitosByPersona(persona.id);
});

/// Progreso de hábitos del día: cuántos hay y cuántos están realizados.
typedef ProgresoHabitos = ({int total, int completados});

/// Progreso de hábitos del día derivado de [habitosProvider]: no hace I/O
/// propio, así que las dos pantallas que lo consumen (el hub de Salud y la
/// banda de progreso de Hábitos) comparten la misma consulta.
///
/// `habito.realizacion` ya viene acotada al día por el origen de datos: acá no
/// se filtra por fecha.
final progresoHabitosHoyProvider = Provider<AsyncValue<ProgresoHabitos>>((ref) {
  return ref
      .watch(habitosProvider)
      .whenData(
        (habitos) => (
          total: habitos.length,
          completados: habitos.where((h) => h.realizacion != null).length,
        ),
      );
});

final habitoByIdProvider = FutureProvider.family<HabitoVida?, int>((
  ref,
  id,
) async {
  final habitos = await ref.watch(habitosProvider.future);
  return habitos.where((h) => h.id == id).firstOrNull;
});

//endregion

//region Acciones Mutadoras

final modificarHabitoProvider =
    Provider<
      Future<void> Function({
        required int habitoId,
        required int tipoId,
        required String descripcion,
      })
    >((ref) {
      return ({
        required habitoId,
        required tipoId,
        required descripcion,
      }) async {
        await ref
            .read(habitoVidaRepositoryProvider)
            .modificarHabito(
              habitoId: habitoId,
              tipoId: tipoId,
              descripcion: descripcion,
            );
        ref.invalidate(habitosProvider);
        ref.invalidate(habitoByIdProvider(habitoId));
      };
    });

final eliminarHabitoProvider =
    Provider<Future<void> Function({required int habitoId})>((ref) {
      return ({required habitoId}) async {
        await ref.read(habitoVidaRepositoryProvider).eliminarHabito(habitoId);
        ref.invalidate(habitosProvider);
      };
    });

final crearHabitoProvider =
    Provider<
      Future<void> Function({required int tipoId, required String descripcion})
    >((ref) {
      return ({required tipoId, required descripcion}) async {
        final persona = await ref.read(
          personaVisualizacionSeleccionadaProvider.future,
        );
        if (persona == null) throw Exception('Sin persona de contexto');
        await ref
            .read(habitoVidaRepositoryProvider)
            .crearHabito(
              personaId: persona.id,
              tipoId: tipoId,
              descripcion: descripcion,
            );
        ref.invalidate(habitosProvider);
      };
    });

final crearRealizacionProvider =
    Provider<
      Future<void> Function({required int habitoId, String? comentarios})
    >((ref) {
      return ({required habitoId, comentarios}) async {
        await ref
            .read(habitoVidaRepositoryProvider)
            .crearRealizacion(habitoId: habitoId, comentarios: comentarios);
        ref.invalidate(habitosProvider);
        ref.invalidate(habitoByIdProvider(habitoId));
      };
    });

final modificarRealizacionProvider =
    Provider<
      Future<void> Function({
        required int habitoId,
        required int realizacionId,
        String? comentarios,
      })
    >((ref) {
      return ({required habitoId, required realizacionId, comentarios}) async {
        await ref
            .read(habitoVidaRepositoryProvider)
            .modificarRealizacion(
              habitoId: habitoId,
              realizacionId: realizacionId,
              comentarios: comentarios,
            );
        ref.invalidate(habitosProvider);
        ref.invalidate(habitoByIdProvider(habitoId));
      };
    });

final eliminarRealizacionProvider =
    Provider<
      Future<void> Function({required int habitoId, required int realizacionId})
    >((ref) {
      return ({required habitoId, required realizacionId}) async {
        await ref
            .read(habitoVidaRepositoryProvider)
            .eliminarRealizacion(
              habitoId: habitoId,
              realizacionId: realizacionId,
            );
        ref.invalidate(habitosProvider);
        ref.invalidate(habitoByIdProvider(habitoId));
      };
    });

//endregion
