import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Todas las asignaciones del usuario logueado (activas, pendientes e inactivas).
final misAsignacionesProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final usuario = ref.watch(authStateProvider).valueOrNull;
      if (usuario == null) return [];
      final repo = ref.watch(asignacionCuidadoRepositoryProvider);
      return repo.obtenerAsignacionesUsuarioLogueado();
    });

//region Asignaciones como Responsable - Providers
final asignacionesComoResponsableProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final todas = await ref.watch(misAsignacionesProvider.future);
      return todas
          .where((a) => a.rol.id == RolesCuidadoConst.responsable)
          .toList();
    });

final asignacionesActivasComoResponsableProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final todasComoResponsable = await ref.watch(
        asignacionesComoResponsableProvider.future,
      );
      return todasComoResponsable
          .where((a) => a.estado.id == EstadosAsignacionConst.activa)
          .toList();
    });
//endregion

//region Asignaciones como Cuidador - Providers
final asignacionesComoCuidadorProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final todas = await ref.watch(misAsignacionesProvider.future);
      return todas
          .where((a) => a.rol.id == RolesCuidadoConst.cuidador)
          .toList();
    });

final asignacionesActivasComoCuidadorProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final todasComoCuidador = await ref.watch(
        asignacionesComoCuidadorProvider.future,
      );
      return todasComoCuidador
          .where((a) => a.estado.id == EstadosAsignacionConst.activa)
          .toList();
    });

final asignacionesPendientesComoCuidadorProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final todasComoCuidador = await ref.watch(
        asignacionesComoCuidadorProvider.future,
      );
      return todasComoCuidador
          .where((a) => a.estado.id == EstadosAsignacionConst.pendiente)
          .toList();
    });
//endregion

final asignacionesActivasProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final comoResponsable = await ref.watch(
        asignacionesActivasComoResponsableProvider.future,
      );
      final comoCuidador = await ref.watch(
        asignacionesActivasComoCuidadorProvider.future,
      );
      return [...comoResponsable, ...comoCuidador];
    });

final miAsignacionPorIdProvider = FutureProvider.autoDispose
    .family<AsignacionCuidado, int>((ref, asignacionId) async {
      final todas = await ref.watch(misAsignacionesProvider.future);
      return todas.firstWhere(
        (a) => a.id == asignacionId,
        orElse: () => throw StateError(
          'Asignación no encontrada en memoria: $asignacionId',
        ),
      );
    });

final asignacionesPorPersonaCuidadaProvider = FutureProvider.autoDispose
    .family<List<AsignacionCuidado>, int>((ref, personaId) async {
      final repo = ref.watch(asignacionCuidadoRepositoryProvider);
      return repo.obtenerAsignacionesPorPersona(personaId);
    });

final esResponsablePersonaSeleccionadaProvider =
    FutureProvider.autoDispose<bool>((ref) async {
      final usuario = ref.watch(authStateProvider).valueOrNull;
      if (usuario == null) return false;

      final esPropio = await ref.watch(esContextoPropioProvider.future);
      if (esPropio) return true;

      final personaCtx = await ref.watch(
        personaVisualizacionSeleccionadaProvider.future,
      );
      if (personaCtx == null) return false;

      final asignaciones = await ref.watch(
        asignacionesPorPersonaCuidadaProvider(personaCtx.id).future,
      );

      return asignaciones.any(
        (a) =>
            a.colaborador.id == usuario.persona.id &&
            a.rol.id == RolesCuidadoConst.responsable &&
            a.estado.id == EstadosAsignacionConst.activa,
      );
    });

final eliminarAsignacionProvider =
    Provider<Future<void> Function({required AsignacionCuidado asignacion})>((
      ref,
    ) {
      return ({required AsignacionCuidado asignacion}) async {
        final repo = ref.read(asignacionCuidadoRepositoryProvider);

        await repo.eliminarAsignacion(asignacion.id);

        ref.invalidate(
          asignacionesPorPersonaCuidadaProvider(asignacion.personaCuidada.id),
        );
        ref.invalidate(misAsignacionesProvider);
      };
    });

/// Permite activar una asignacion que se le fue notificada.
final activarAsignacionProvider =
    Provider<Future<void> Function({required AsignacionCuidado asignacion})>((
      ref,
    ) {
      return ({required AsignacionCuidado asignacion}) async {
        final repo = ref.read(asignacionCuidadoRepositoryProvider);

        await repo.activarAsignacion(asignacion.id);

        ref.invalidate(
          asignacionesPorPersonaCuidadaProvider(asignacion.personaCuidada.id),
        );
        ref.invalidate(misAsignacionesProvider);
      };
    });

/// Permite reactivar un miembro recientemente eliminado.
final reactivarAsignacionProvider =
    Provider<Future<void> Function({required AsignacionCuidado asignacion})>((
      ref,
    ) {
      return ({required AsignacionCuidado asignacion}) async {
        final repo = ref.read(asignacionCuidadoRepositoryProvider);

        await repo.reactivarAsignacion(asignacion.id);

        ref.invalidate(
          asignacionesPorPersonaCuidadaProvider(asignacion.personaCuidada.id),
        );
        ref.invalidate(misAsignacionesProvider);
      };
    });
