import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
