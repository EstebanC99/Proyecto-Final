import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final mesLineaTiempoProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

final lineaTiempoDelMesProvider = FutureProvider<List<EventoBase>>((ref) async {
  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return [];

  final mes = ref.watch(mesLineaTiempoProvider);
  final desde = mes;
  final hasta = DateTime(mes.year, mes.month + 1, 1);

  final eventos = await ref
      .watch(lineaTiempoSaludRepositoryProvider)
      .getEventosPorFechas(personaId: persona.id, desde: desde, hasta: hasta);
  eventos.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  return eventos;
});

/// Categoría por la que se filtra la línea de tiempo. `null` = todas.
final filtroCategoriaTimelineProvider = StateProvider<String?>((ref) => null);

/// Registros del mes agrupados por día, listos para pintar.
///
/// El cálculo vive acá y no en el widget para que se rehaga sólo cuando cambian
/// los datos, y no en cada rebuild (cambio de tema, de escala tipográfica o de
/// filtro).
final lineaTiempoAgrupadaProvider =
    Provider<AsyncValue<List<GrupoDiaTimeline>>>((ref) {
      final filtro = ref.watch(filtroCategoriaTimelineProvider);
      return ref.watch(lineaTiempoDelMesProvider).whenData((eventos) {
        // El filtro se aplica antes de agrupar: si no, quedarían días con la
        // tarjeta vacía y el contador en cero.
        final visibles = filtro == null
            ? eventos
            : eventos.where((e) => e.categoriaEvento == filtro).toList();
        return agruparPorDia(visibles);
      });
    });
