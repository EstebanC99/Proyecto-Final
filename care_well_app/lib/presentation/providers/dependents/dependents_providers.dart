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
  final repo = ref.watch(careTeamRepositoryProvider);
  final asignaciones = await repo.getAsignacionesByColaborador(
    usuario.persona.id,
  );
  return asignaciones
      .where(
        (a) =>
            a.rol.nombre == RolCuidado.responsable &&
            a.estado == EstadoAsignacion.activa,
      )
      .map((a) => a.personaCuidada)
      .toList();
});

/// Personas donde el usuario autenticado actúa como Cuidador (asignación activa).
final dependentsAsCuidadorProvider = FutureProvider<List<Persona>>((ref) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return [];
  final repo = ref.watch(careTeamRepositoryProvider);
  final asignaciones = await repo.getAsignacionesByColaborador(
    usuario.persona.id,
  );
  return asignaciones
      .where(
        (a) =>
            a.rol.nombre == RolCuidado.cuidador &&
            a.estado == EstadoAsignacion.activa,
      )
      .map((a) => a.personaCuidada)
      .toList();
});

/// Persona por ID.
final dependentByIdProvider = FutureProvider.family<Persona, String>((
  ref,
  personaId,
) async {
  final repo = ref.watch(personaRepositoryProvider);
  return repo.getById(personaId);
});

/// FutureProvider que expone la lista de personas a cargo del usuario autenticado.
///
/// Mantiene compatibilidad con [HomeScreen] y otros consumidores previos.
final dependentsListProvider = FutureProvider<List<Persona>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final usuario = authState.valueOrNull;
  if (usuario == null) return [];
  final repo = ref.watch(personaRepositoryProvider);
  return repo.getDependientesByUsuario(usuario.id);
});

// ─── Acciones mutadoras ───────────────────────────────────────────────────────

/// Crea una nueva persona a cargo y la vincula al usuario como Responsable.
///
/// Invalidar los providers de lista tras el éxito.
final crearDependenteProvider =
    Provider<
      Future<Persona> Function({
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

        final personaRepo = ref.read(personaRepositoryProvider);
        final careTeamRepo = ref.read(careTeamRepositoryProvider);

        // 1. Crear la persona sin ID (la datasource genera el ID).
        final nueva = await personaRepo.crear(
          Persona(
            id: '',
            nombre: nombre,
            apellido: apellido,
            documento: documento,
            fechaNacimiento: fechaNacimiento,
            email: email,
            telefono: telefono,
            imagen: imagen,
          ),
        );

        // 2. Obtener el rol Responsable.
        final roles = await careTeamRepo.getRoles();
        final rolResponsable = roles.firstWhere(
          (r) => r.nombre == RolCuidado.responsable,
        );

        // 3. Crear la asignación.
        await careTeamRepo.crearAsignacion(
          AsignacionCuidado(
            id: '',
            personaCuidada: nueva,
            personaColaborador: usuario.persona,
            rol: rolResponsable,
            estado: EstadoAsignacion.activa,
            fechaAlta: DateTime.now(),
          ),
        );

        // 4. Invalidar listas para que se recarguen.
        ref.invalidate(dependentsAsResponsableProvider);
        ref.invalidate(dependentsListProvider);

        return nueva;
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
    Provider<Future<void> Function(String personaId)>((ref) {
      return (personaId) async {
        final repo = ref.read(personaRepositoryProvider);
        await repo.eliminar(personaId);
        ref.invalidate(dependentsAsResponsableProvider);
        ref.invalidate(dependentsListProvider);
      };
    });
