import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fichaSaludProvider = FutureProvider.autoDispose<FichaSalud?>((ref) async {
  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return null;

  return ref.watch(fichaSaludRepositoryProvider).getFichaSalud(persona);
});

final guardarFichaSaludProvider = Provider<Future<void> Function(FichaSalud)>((
  ref,
) {
  final repo = ref.watch(fichaSaludRepositoryProvider);
  return (FichaSalud ficha) => repo.guardarFichaSalud(ficha);
});
