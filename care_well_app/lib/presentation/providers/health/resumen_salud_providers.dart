import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resumen de salud de la persona de contexto: alimenta las cuatro tarjetas
/// del hub de Mi salud con una sola consulta.
///
/// Es `autoDispose` porque el hub es transitorio. Las mutaciones de salud
/// (realización de hábito, registro de ánimo, alta/baja de evento y guardado de
/// ficha) lo invalidan para que el hub no quede con números viejos al volver.
final resumenSaludProvider = FutureProvider.autoDispose<ResumenSalud?>((
  ref,
) async {
  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return null;

  return ref.watch(resumenSaludRepositoryProvider).getResumenSalud(persona);
});
