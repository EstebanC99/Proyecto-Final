import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Catálogo de tipos de hábito de vida (fuente única: backend).
final tiposHabitoVidaProvider = FutureProvider<List<TipoHabitoVida>>((
  ref,
) async {
  return ref.watch(tipoHabitoVidaRepositoryProvider).obtenerTiposHabitosVida();
});
