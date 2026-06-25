import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/entities.dart';
import '../di_providers.dart';
import '../auth/auth_providers.dart';

/// Personas donde el usuario autenticado actúa como Responsable (asignación activa).
final dependentsAsResponsableProvider = FutureProvider<List<Persona>>((
  ref,
) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return [];
  final repo = ref.watch(asignacionCuidadoRepositoryProvider);
  final asignaciones = await repo.obtenerAsignacionesUsuarioLogueado();
  return asignaciones
      .where(
        (a) =>
            a.rol.id == RolesCuidadoConst.responsable &&
            a.estado.id == EstadosAsignacionConst.activa,
      )
      .map((a) => a.personaCuidada)
      .toList();
});

/// Personas donde el usuario autenticado actúa como Cuidador (asignación activa).
final dependentsAsCuidadorProvider = FutureProvider<List<Persona>>((ref) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return [];
  final repo = ref.watch(asignacionCuidadoRepositoryProvider);
  final asignaciones = await repo.obtenerAsignacionesUsuarioLogueado();
  return asignaciones
      .where(
        (a) =>
            a.rol.id == RolesCuidadoConst.cuidador &&
            a.estado.id == EstadosAsignacionConst.activa,
      )
      .map((a) => a.personaCuidada)
      .toList();
});

/// Persona por ID.
final dependentByIdProvider = FutureProvider.family<Persona, int>((
  ref,
  personaId,
) async {
  final repo = ref.watch(personaRepositoryProvider);
  return repo.getById(personaId);
});

// ─── Acciones mutadoras ───────────────────────────────────────────────────────

/// Crea una nueva persona a cargo y la vincula al usuario como Responsable.
///
/// Delega a [AsignacionCuidadoRepository.crearPersonaCargo], que en modo API
/// realiza la operación de forma atómica y en modo demo registra la
/// [Persona] y la [AsignacionCuidado] en memoria.
///
/// Invalida los providers de lista tras el éxito.
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

        // Una sola llamada: el backend crea Persona + AsignacionCuidado
        // de forma atómica (rol Responsable, estado Activa).
        await asignacionRepo.crearPersonaCargo(
          nombre: nombre,
          apellido: apellido,
          documento: documento,
          fechaNacimiento: fechaNacimiento,
          email: email,
          telefono: telefono,
          // MVP: sin permisos adicionales.
          permisosCuidadoIds: const [],
        );

        // Invalidar listas para que se recarguen.
        ref.invalidate(dependentsAsResponsableProvider);
      };
    });

/// Actualiza los datos de una persona a cargo existente.
final actualizarDependenteProvider =
    Provider<Future<Persona> Function(Persona persona)>((ref) {
      return (persona) async {
        final repo = ref.read(personaRepositoryProvider);
        final actualizada = await repo.actualizar(persona);
        ref.invalidate(dependentByIdProvider(persona.id));
        return actualizada;
      };
    });

/// Elimina una persona a cargo.
final eliminarDependenteProvider =
    Provider<Future<void> Function(int personaId)>((ref) {
      return (personaId) async {
        final repo = ref.read(personaRepositoryProvider);
        await repo.eliminar(personaId);
        ref.invalidate(dependentsAsResponsableProvider);
      };
    });
