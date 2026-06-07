import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/entities.dart';
import '../auth/auth_providers.dart';
import '../dependents/dependents_providers.dart';
import '../di_providers.dart';

// ─── Selector de persona de contexto global ───────────────────────────────────

/// Rol de la persona respecto al usuario autenticado en el selector de contexto.
enum PersonaContextRol { propio, responsable, cuidador }

/// Opción de persona seleccionable en el selector de contexto global.
class PersonaContextOption {
  final Persona persona;
  final PersonaContextRol rol;

  const PersonaContextOption({required this.persona, required this.rol});
}

/// ID de la persona cuyo contexto se está visualizando.
/// `null` = sin selección explícita → usa el default (primera persona a cargo como
/// Responsable; si no hay ninguna, el propio usuario).
final selectedPersonaIdProvider = StateProvider<String?>((ref) => null);

/// Lista completa de personas que el usuario puede seleccionar como contexto:
/// 1. El propio usuario (etiquetado con rol [PersonaContextRol.propio]).
/// 2. Personas donde es Responsable.
/// 3. Personas donde es Cuidador.
final personasSeleccionablesProvider =
    FutureProvider<List<PersonaContextOption>>((ref) async {
      final usuario = ref.watch(authStateProvider).valueOrNull;
      if (usuario == null) return [];

      final comoResponsable = await ref.watch(
        dependentsAsResponsableProvider.future,
      );
      final comoCuidador = await ref.watch(dependentsAsCuidadorProvider.future);

      return [
        PersonaContextOption(
          persona: usuario.persona,
          rol: PersonaContextRol.propio,
        ),
        ...comoResponsable.map(
          (p) => PersonaContextOption(
            persona: p,
            rol: PersonaContextRol.responsable,
          ),
        ),
        ...comoCuidador.map(
          (p) =>
              PersonaContextOption(persona: p, rol: PersonaContextRol.cuidador),
        ),
      ];
    });

/// Persona de contexto activa, seleccionada globalmente.
///
/// Cuando [selectedPersonaIdProvider] es `null`, el comportamiento default es:
/// primera persona donde el usuario es Responsable; si no hay ninguna, el propio usuario.
/// Esto preserva el contrato previo de [careTeamContextPersonaProvider].
final careTeamContextPersonaProvider = FutureProvider<Persona?>((ref) async {
  final opciones = await ref.watch(personasSeleccionablesProvider.future);
  if (opciones.isEmpty) return null;

  final selectedId = ref.watch(selectedPersonaIdProvider);

  if (selectedId == null) {
    // Default: primera persona a cargo como Responsable; si no hay, el propio usuario.
    final comoResponsable = opciones.where(
      (o) => o.rol == PersonaContextRol.responsable,
    );
    return comoResponsable.isNotEmpty
        ? comoResponsable.first.persona
        : opciones.first.persona;
  }

  return opciones
      .map((o) => o.persona)
      .firstWhere(
        (p) => p.id == selectedId,
        orElse: () => opciones.first.persona,
      );
});

/// Asignaciones de cuidado de una persona cuidada específica.
final careTeamAssignmentsProvider =
    FutureProvider.family<List<AsignacionCuidado>, String>((
      ref,
      personaId,
    ) async {
      final repo = ref.watch(careTeamRepositoryProvider);
      return repo.getAsignacionesByPersonaCuidada(personaId);
    });

/// Asignación por ID. Busca en las asignaciones de la persona de contexto.
///
/// Retorna `null` si no existe.
final assignmentByIdProvider =
    FutureProvider.family<AsignacionCuidado?, String>((
      ref,
      asignacionId,
    ) async {
      final personaCtx = await ref.watch(careTeamContextPersonaProvider.future);
      if (personaCtx == null) return null;
      final asignaciones = await ref.watch(
        careTeamAssignmentsProvider(personaCtx.id).future,
      );
      try {
        return asignaciones.firstWhere((a) => a.id == asignacionId);
      } catch (_) {
        return null;
      }
    });

/// Catálogo completo de códigos de permiso disponibles.
final availablePermisosProvider = Provider<List<CodigoPermiso>>(
  (ref) => CodigoPermiso.values,
);

// ─── Etiquetas de permisos ────────────────────────────────────────────────────

/// Retorna la etiqueta legible de un [CodigoPermiso].
String labelDePermiso(CodigoPermiso codigo) {
  switch (codigo) {
    case CodigoPermiso.verFichaSalud:
      return 'Ver ficha de salud';
    case CodigoPermiso.editarFichaSalud:
      return 'Editar ficha de salud';
    case CodigoPermiso.gestionarAgenda:
      return 'Gestionar agenda';
    case CodigoPermiso.registrarEventosSalud:
      return 'Registrar eventos de salud';
    case CodigoPermiso.registrarHabitos:
      return 'Registrar hábitos de vida';
    case CodigoPermiso.activarEmergencia:
      return 'Activar emergencia';
    case CodigoPermiso.administrarEquipo:
      return 'Administrar equipo de cuidado';
  }
}

// ─── Acciones mutadoras ───────────────────────────────────────────────────────

/// Agrega un nuevo miembro al equipo de cuidado de la persona de contexto.
///
/// Busca en el seed si existe una Persona con ese email; si no, crea un
/// placeholder con `nombre` extraído del email.
/// DEMO: el lookup por email es simplificado y busca en el repositorio local.
final crearMiembroProvider =
    Provider<
      Future<AsignacionCuidado> Function({
        required String personaCuidadaId,
        required String email,
        required List<CodigoPermiso> permisos,
        required RolCuidado rolNombre,
      })
    >((ref) {
      return ({
        required personaCuidadaId,
        required email,
        required permisos,
        required rolNombre,
      }) async {
        final careTeamRepo = ref.read(careTeamRepositoryProvider);
        final personaRepo = ref.read(personaRepositoryProvider);

        // DEMO: lookup simplificado — busca persona por email, si no crea placeholder.
        Persona colaborador;
        try {
          // Intentar obtener desde una búsqueda (en demo: getById no aplica, buscar en lista)
          // Como no hay búsqueda por email, creamos un placeholder para demo.
          throw Exception('lookup no disponible en demo');
        } catch (_) {
          colaborador = await personaRepo.crear(
            Persona(
              id: '',
              nombre: email.split('@').first,
              apellido: '',
              email: email,
            ),
          );
        }

        // Obtener el rol correspondiente.
        final roles = await careTeamRepo.getRoles();
        final rol = roles.firstWhere((r) => r.nombre == rolNombre);

        // Construir permisos con los códigos seleccionados.
        final permisosSeleccionados = permisos.map((codigo) {
          final id = 'prm_new_${codigo.name}';
          return Permiso(
            id: id,
            codigo: codigo,
            descripcion: labelDePermiso(codigo),
          );
        }).toList();

        final rolConPermisos = rol.copyWith(permisos: permisosSeleccionados);

        final personaCuidada = await personaRepo.getById(personaCuidadaId);

        final asignacion = await careTeamRepo.crearAsignacion(
          AsignacionCuidado(
            id: '',
            personaCuidada: personaCuidada,
            personaColaborador: colaborador,
            rol: rolConPermisos,
            estado: EstadoAsignacion.activa,
            fechaAlta: DateTime.now(),
          ),
        );

        // Invalidar listas.
        ref.invalidate(careTeamAssignmentsProvider(personaCuidadaId));

        return asignacion;
      };
    });

/// Actualiza los permisos de una asignación existente.
final actualizarPermisosProvider =
    Provider<
      Future<void> Function({
        required AsignacionCuidado asignacion,
        required List<CodigoPermiso> permisosActivos,
      })
    >((ref) {
      return ({required asignacion, required permisosActivos}) async {
        final repo = ref.read(careTeamRepositoryProvider);

        final nuevosPermisos = permisosActivos.map((codigo) {
          // Reusar el permiso existente si ya estaba, o crear uno nuevo.
          final existente = asignacion.rol.permisos
              .where((p) => p.codigo == codigo)
              .firstOrNull;
          return existente ??
              Permiso(
                id: 'prm_${codigo.name}',
                codigo: codigo,
                descripcion: labelDePermiso(codigo),
              );
        }).toList();

        final rolActualizado = asignacion.rol.copyWith(
          permisos: nuevosPermisos,
        );
        final asignacionActualizada = asignacion.copyWith(rol: rolActualizado);

        await repo.actualizarAsignacion(asignacionActualizada);

        ref.invalidate(
          careTeamAssignmentsProvider(asignacion.personaCuidada.id),
        );
        ref.invalidate(assignmentByIdProvider(asignacion.id));
      };
    });

/// Elimina (da de baja) un miembro del equipo.
///
/// En producción se marcaría como inactivo; en demo se elimina de la lista.
final eliminarMiembroProvider =
    Provider<
      Future<void> Function({
        required String asignacionId,
        required String personaCuidadaId,
      })
    >((ref) {
      return ({required asignacionId, required personaCuidadaId}) async {
        final repo = ref.read(careTeamRepositoryProvider);
        await repo.eliminarAsignacion(asignacionId);
        ref.invalidate(careTeamAssignmentsProvider(personaCuidadaId));
        ref.invalidate(assignmentByIdProvider(asignacionId));
      };
    });

/// `true` si la persona de contexto actualmente seleccionada es el propio usuario autenticado.
///
/// Se usa como cortocircuito en los providers de permisos: cuando el usuario
/// visualiza su propio contexto ("Yo"), tiene acceso completo sin necesidad de
/// una [AsignacionCuidado].
final esContextoPropioProvider = FutureProvider<bool>((ref) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return false;
  final persona = await ref.watch(careTeamContextPersonaProvider.future);
  if (persona == null) return false;
  return persona.id == usuario.persona.id;
});

/// Indica si el usuario autenticado es Responsable de la persona de contexto.
final esResponsableProvider = FutureProvider<bool>((ref) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return false;
  final personaCtx = await ref.watch(careTeamContextPersonaProvider.future);
  if (personaCtx == null) return false;
  final asignaciones = await ref.watch(
    careTeamAssignmentsProvider(personaCtx.id).future,
  );
  return asignaciones.any(
    (a) =>
        a.personaColaborador.id == usuario.persona.id &&
        a.rol.nombre == RolCuidado.responsable &&
        a.estado == EstadoAsignacion.activa,
  );
});
