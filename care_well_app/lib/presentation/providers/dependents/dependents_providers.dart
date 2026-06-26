import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/entities.dart';
import '../di_providers.dart';
import '../auth/auth_providers.dart';

// ─── Provider base ────────────────────────────────────────────────────────────

/// Todas las asignaciones del usuario logueado (activas, pendientes e inactivas).
final misAsignacionesProvider = FutureProvider<List<AsignacionCuidado>>((
  ref,
) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return [];
  final repo = ref.watch(asignacionCuidadoRepositoryProvider);
  return repo.obtenerAsignacionesUsuarioLogueado();
});

// ─── Providers derivados ──────────────────────────────────────────────────────

/// Asignaciones donde el usuario actúa como Responsable (activas o pendientes).
final dependentsAsResponsableProvider = FutureProvider<List<AsignacionCuidado>>(
  (ref) async {
    final todas = await ref.watch(misAsignacionesProvider.future);
    return todas
        .where(
          (a) =>
              a.rol.id == RolesCuidadoConst.responsable &&
              a.estado.id != EstadosAsignacionConst.inactiva,
        )
        .toList();
  },
);

/// Asignaciones donde el usuario actúa como Cuidador (activas o pendientes).
final dependentsAsCuidadorProvider = FutureProvider<List<AsignacionCuidado>>((
  ref,
) async {
  final todas = await ref.watch(misAsignacionesProvider.future);
  return todas
      .where(
        (a) =>
            a.rol.id == RolesCuidadoConst.cuidador &&
            a.estado.id != EstadosAsignacionConst.inactiva,
      )
      .toList();
});

/// Asignación por ID, buscada en memoria (sin llamada al backend).
final asignacionByIdProvider = FutureProvider.family<AsignacionCuidado, int>((
  ref,
  asignacionId,
) async {
  final todas = await ref.watch(misAsignacionesProvider.future);
  return todas.firstWhere(
    (a) => a.id == asignacionId,
    orElse: () =>
        throw StateError('Asignación no encontrada en memoria: $asignacionId'),
  );
});

// ─── Acciones mutadoras ───────────────────────────────────────────────────────

/// Crea una nueva persona a cargo y la vincula al usuario como Responsable.
final crearDependenteProvider =
    Provider<
      Future<void> Function({
        required String nombre,
        required String apellido,
        required String documento,
        required DateTime fechaNacimiento,
        String? email,
        String? telefono,
        String? imagen,
      })
    >((ref) {
      return ({
        required nombre,
        required apellido,
        required documento,
        required fechaNacimiento,
        email,
        telefono,
        imagen,
      }) async {
        final usuario = ref.read(authStateProvider).valueOrNull;
        if (usuario == null) throw Exception('No hay sesión activa.');

        final asignacionRepo = ref.read(asignacionCuidadoRepositoryProvider);

        await asignacionRepo.crearPersonaCargo(
          nombre: nombre,
          apellido: apellido,
          documento: documento,
          fechaNacimiento: fechaNacimiento,
          email: email,
          telefono: telefono,
        );

        // Invalidar lista base para que se recargue.
        ref.invalidate(misAsignacionesProvider);
      };
    });

/// Actualiza los datos de una persona a cargo existente.
///
/// Recibe el [asignacionId] para que el backend pueda validar los permisos
/// del usuario logueado antes de aplicar los cambios.
final actualizarDependenteProvider =
    Provider<Future<Persona> Function(int asignacionId, Persona persona)>((
      ref,
    ) {
      return (asignacionId, persona) async {
        final repo = ref.read(asignacionCuidadoRepositoryProvider);
        final actualizada = await repo.modificarPersonaCargo(
          asignacionId,
          persona,
        );
        ref.invalidate(misAsignacionesProvider);
        return actualizada;
      };
    });

/// Elimina una persona a cargo.
final eliminarDependenteProvider =
    Provider<Future<void> Function(int personaId)>((ref) {
      return (personaId) async {
        final repo = ref.read(personaRepositoryProvider);
        await repo.eliminar(personaId);
        ref.invalidate(misAsignacionesProvider);
      };
    });
