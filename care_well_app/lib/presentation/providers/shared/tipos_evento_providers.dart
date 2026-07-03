import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/di_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Catálogo completo de tipos de evento (agendables y no agendables).
final tiposEventoProvider = FutureProvider<List<TipoEvento>>((ref) async {
  return ref.watch(tipoEventoRepositoryProvider).obtenerTiposEvento();
});

/// Tipos de evento que pueden seleccionarse al crear un evento
/// (derivado de [tiposEventoProvider], filtrando por [TipoEvento.agendable]).
final tiposEventoAgendablesProvider = FutureProvider<List<TipoEvento>>((ref) {
  return ref
      .watch(tiposEventoProvider.future)
      .then((tipos) => tipos.where((t) => t.agendable).toList());
});
