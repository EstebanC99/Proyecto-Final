import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asignación por ID. Busca en las asignaciones de la persona de contexto.
final asignacionPersonaSeleccionadaPorIdProvider = FutureProvider.autoDispose
    .family<AsignacionCuidado?, int>((ref, asignacionId) async {
      final personaSeleccionada = await ref.watch(
        personaVisualizacionSeleccionadaProvider.future,
      );

      if (personaSeleccionada == null) return null;

      final asignaciones = await ref.watch(
        asignacionesPorPersonaCuidadaProvider(personaSeleccionada.id).future,
      );

      try {
        return asignaciones.firstWhere((a) => a.id == asignacionId);
      } catch (_) {
        return null;
      }
    });

/// Agrega un nuevo miembro al equipo de cuidado de la persona de contexto.
final crearMiembroProvider =
    Provider<
      Future<void> Function({
        required int personaCuidadaId,
        required String email,
        required List<PermisoCuidado> permisos,
        required RolCuidado rol,
      })
    >((ref) {
      return ({
        required personaCuidadaId,
        required email,
        required permisos,
        required rol,
      }) async {
        final repo = ref.read(asignacionCuidadoRepositoryProvider);

        await repo.asignarPersonaEquipoCuidado(
          personaCuidadaId: personaCuidadaId,
          colaboradorEmail: email.trim(),
          rolCuidadoId: rol.id,
          permisosCuidadoIds: permisos.map((p) => p.id).toList(),
        );

        ref.invalidate(asignacionesPorPersonaCuidadaProvider(personaCuidadaId));
      };
    });

/// Actualiza los permisos de una asignación existente.
final actualizarPermisosProvider =
    Provider<
      Future<void> Function({
        required AsignacionCuidado asignacion,
        required List<PermisoCuidado> permisosActivos,
      })
    >((ref) {
      return ({required asignacion, required permisosActivos}) async {
        final repo = ref.read(asignacionCuidadoRepositoryProvider);

        await repo.modificarPermisosAsignacion(
          asignacionId: asignacion.id,
          permisosSeleccionados: permisosActivos,
        );

        ref.invalidate(
          asignacionesPorPersonaCuidadaProvider(asignacion.personaCuidada.id),
        );
        ref.invalidate(misAsignacionesProvider);
      };
    });
