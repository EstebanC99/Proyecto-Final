import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/auth/auth_providers.dart';
import 'package:care_well_app/presentation/providers/di_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Provider base ────────────────────────────────────────────────────────────

/// Todas las asignaciones del usuario logueado (activas, pendientes e inactivas).
final misAsignacionesProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final usuario = ref.watch(authStateProvider).valueOrNull;
      if (usuario == null) return [];
      final repo = ref.watch(asignacionCuidadoRepositoryProvider);
      return repo.obtenerAsignacionesUsuarioLogueado();
    });

// ─── Providers derivados ──────────────────────────────────────────────────────

final activeAssignmentsAsResponsableProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final todas = await ref.watch(misAsignacionesProvider.future);
      return todas
          .where(
            (a) =>
                a.rol.id == RolesCuidadoConst.responsable &&
                a.estado.id != EstadosAsignacionConst.inactiva,
          )
          .toList();
    });

final activeAssignmentsAsCuidadorProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final todas = await ref.watch(misAsignacionesProvider.future);
      return todas
          .where(
            (a) =>
                a.rol.id == RolesCuidadoConst.cuidador &&
                a.estado.id != EstadosAsignacionConst.inactiva,
          )
          .toList();
    });

/// Todas las asignaciones activas del usuario, sin importar el rol
/// (Responsable o Cuidador). Une [activeAssignmentsAsResponsableProvider] y
/// [activeAssignmentsAsCuidadorProvider]. Alimenta el tile de "Personas a cargo"
/// del Home, que debe mostrarse en estado normal ante cualquier asignación activa.
final allActiveAssignmentsProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final comoResponsable = await ref.watch(
        activeAssignmentsAsResponsableProvider.future,
      );
      final comoCuidador = await ref.watch(
        activeAssignmentsAsCuidadorProvider.future,
      );
      return [...comoResponsable, ...comoCuidador];
    });

final assignmentsAsResponsableProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final todas = await ref.watch(misAsignacionesProvider.future);
      return todas
          .where((a) => a.rol.id == RolesCuidadoConst.responsable)
          .toList();
    });

final assignmentsAsCuidadorProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final todas = await ref.watch(misAsignacionesProvider.future);
      return todas
          .where((a) => a.rol.id == RolesCuidadoConst.cuidador)
          .toList();
    });

/// Invitaciones de cuidado pendientes de aceptación donde el usuario es Cuidador.
///
/// Derivado de [misAsignacionesProvider]: filtra rol Cuidador en estado
/// pendiente. Alimenta la sección de invitaciones de [DependentsScreen].
final pendingAssignmentsAsCuidadorProvider =
    FutureProvider.autoDispose<List<AsignacionCuidado>>((ref) async {
      final todas = await ref.watch(misAsignacionesProvider.future);
      return todas
          .where(
            (a) =>
                a.rol.id == RolesCuidadoConst.cuidador &&
                a.estado.id == EstadosAsignacionConst.pendiente,
          )
          .toList();
    });

final asignacionByIdProvider = FutureProvider.autoDispose
    .family<AsignacionCuidado, int>((ref, asignacionId) async {
      final todas = await ref.watch(misAsignacionesProvider.future);
      return todas.firstWhere(
        (a) => a.id == asignacionId,
        orElse: () => throw StateError(
          'Asignación no encontrada en memoria: $asignacionId',
        ),
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
    Provider<Future<void> Function(int asignacionId)>((ref) {
      return (asignacionId) async {
        final repo = ref.read(asignacionCuidadoRepositoryProvider);

        await repo.eliminarAsignacion(asignacionId);

        ref.invalidate(misAsignacionesProvider);
      };
    });

/// Activa una asignación pendiente (dentro del plazo de gracia).
final activarDependenteProvider =
    Provider<Future<void> Function(int asignacionId)>((ref) {
      return (asignacionId) async {
        final repo = ref.read(asignacionCuidadoRepositoryProvider);

        await repo.activarAsignacion(asignacionId);

        ref.invalidate(misAsignacionesProvider);
      };
    });

/// Reactiva una asignación previamente eliminada (dentro del plazo de gracia).
final reactivarDependenteProvider =
    Provider<Future<void> Function(int asignacionId)>((ref) {
      return (asignacionId) async {
        final repo = ref.read(asignacionCuidadoRepositoryProvider);

        await repo.reactivarAsignacion(asignacionId);

        ref.invalidate(misAsignacionesProvider);
      };
    });
