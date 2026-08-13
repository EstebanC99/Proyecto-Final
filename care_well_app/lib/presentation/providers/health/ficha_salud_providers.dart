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
  return (FichaSalud ficha) async {
    await repo.guardarFichaSalud(ficha);
    // La ficha se muestra fuera de su pantalla (chips del hub de Salud): sin
    // invalidar, esas vistas quedan con los datos previos al guardado.
    ref.invalidate(fichaSaludProvider);
  };
});
