import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

//region Acciones de Consulta

final mesEventosSaludProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

final eventosSaludDelMesProvider = FutureProvider<List<EventoSalud>>((
  ref,
) async {
  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return [];

  final mes = ref.watch(mesEventosSaludProvider);
  final desde = mes;
  final hasta = DateTime(mes.year, mes.month + 1, 1);

  final eventos = await ref
      .watch(eventoSaludRepositoryProvider)
      .getEventosSaludDelMes(personaId: persona.id, desde: desde, hasta: hasta);
  eventos.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  return eventos;
});

final eventoSaludByIdProvider = FutureProvider.family<EventoSalud?, int>((
  ref,
  id,
) async {
  final eventos = await ref.watch(eventosSaludDelMesProvider.future);
  return eventos.where((e) => e.id == id).firstOrNull;
});

final notasByEventoProvider = Provider.family<List<NotaEventoSalud>, int>((
  ref,
  eventoId,
) {
  final eventos = ref.watch(eventosSaludDelMesProvider).value ?? [];
  final evento = eventos.where((e) => e.id == eventoId).firstOrNull;
  final notas = [...?evento?.notas];
  notas.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  return notas;
});

//endregion

//region Acciones Mutadoras

final crearEventoSaludProvider =
    Provider<
      Future<void> Function({
        required int tipoId,
        required String descripcion,
        required DateTime fechaHora,
      })
    >((ref) {
      return ({
        required tipoId,
        required descripcion,
        required fechaHora,
      }) async {
        final persona = await ref.read(
          personaVisualizacionSeleccionadaProvider.future,
        );
        if (persona == null) throw Exception('Sin persona de contexto');

        await ref
            .read(eventoSaludRepositoryProvider)
            .crearEventoSalud(
              personaId: persona.id,
              tipoId: tipoId,
              fechaHora: fechaHora,
              descripcion: descripcion,
            );
        ref.invalidate(eventosSaludDelMesProvider);
      };
    });

final eliminarEventoSaludProvider =
    Provider<Future<void> Function({required int eventoId})>((ref) {
      return ({required eventoId}) async {
        await ref
            .read(eventoSaludRepositoryProvider)
            .eliminarEventoSalud(eventoId);
        ref.invalidate(eventosSaludDelMesProvider);
      };
    });

final agregarNotaEventoProvider =
    Provider<
      Future<void> Function({
        required int eventoSaludId,
        required String contenido,
      })
    >((ref) {
      return ({required eventoSaludId, required contenido}) async {
        await ref
            .read(eventoSaludRepositoryProvider)
            .agregarNota(eventoSaludId: eventoSaludId, contenido: contenido);
        ref.invalidate(eventosSaludDelMesProvider);
      };
    });

final modificarNotaEventoProvider =
    Provider<
      Future<void> Function({
        required int eventoSaludId,
        required int notaId,
        required String contenido,
      })
    >((ref) {
      return ({
        required eventoSaludId,
        required notaId,
        required contenido,
      }) async {
        await ref
            .read(eventoSaludRepositoryProvider)
            .modificarNota(
              eventoSaludId: eventoSaludId,
              notaId: notaId,
              contenido: contenido,
            );
        ref.invalidate(eventosSaludDelMesProvider);
      };
    });

final eliminarNotaEventoProvider =
    Provider<
      Future<void> Function({required int eventoSaludId, required int notaId})
    >((ref) {
      return ({required eventoSaludId, required notaId}) async {
        await ref
            .read(eventoSaludRepositoryProvider)
            .eliminarNota(eventoSaludId: eventoSaludId, notaId: notaId);
        ref.invalidate(eventosSaludDelMesProvider);
      };
    });

//endregion
