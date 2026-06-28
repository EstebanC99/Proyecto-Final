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
final selectedPersonaIdProvider = StateProvider<int?>((ref) => null);

/// Lista completa de personas que el usuario puede seleccionar como contexto:
/// 1. El propio usuario (etiquetado con rol [PersonaContextRol.propio]).
/// 2. Personas donde es Responsable.
/// 3. Personas donde es Cuidador.
final personasSeleccionablesProvider =
    FutureProvider.autoDispose<List<PersonaContextOption>>((ref) async {
      final usuario = ref.watch(authStateProvider).valueOrNull;
      if (usuario == null) return [];

      final comoResponsable = await ref.watch(
        activeAssignmentsAsResponsableProvider.future,
      );
      final comoCuidador = await ref.watch(
        activeAssignmentsAsCuidadorProvider.future,
      );

      return [
        PersonaContextOption(
          persona: usuario.persona,
          rol: PersonaContextRol.propio,
        ),
        ...comoResponsable
            .where((a) => a.estado.id == EstadosAsignacionConst.activa)
            .map(
              (a) => PersonaContextOption(
                persona: a.personaCuidada,
                rol: PersonaContextRol.responsable,
              ),
            ),
        ...comoCuidador
            .where((a) => a.estado.id == EstadosAsignacionConst.activa)
            .map(
              (a) => PersonaContextOption(
                persona: a.personaCuidada,
                rol: PersonaContextRol.cuidador,
              ),
            ),
      ];
    });

/// Persona de contexto activa, seleccionada globalmente.
///
/// Cuando [selectedPersonaIdProvider] es `null`, el comportamiento default es:
/// primera persona donde el usuario es Responsable; si no hay ninguna, el propio usuario.
final careTeamContextPersonaProvider = FutureProvider.autoDispose<Persona?>((
  ref,
) async {
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
final careTeamAssignmentsProvider = FutureProvider.autoDispose
    .family<List<AsignacionCuidado>, int>((ref, personaId) async {
      final repo = ref.watch(asignacionCuidadoRepositoryProvider);
      return repo.obtenerAsignacionesPorPersona(personaId);
    });

/// Asignación por ID. Busca en las asignaciones de la persona de contexto.
///
/// Retorna `null` si no existe.
final assignmentByIdProvider = FutureProvider.autoDispose
    .family<AsignacionCuidado?, int>((ref, asignacionId) async {
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
///
/// Lista estática que reemplaza el antiguo [CodigoPermiso.values] del enum.
final _todosCodigos = [
  PermisoCuidado(
    id: PermisosCuidadoConst.verFichaSalud,
    descripcion: 'Ver ficha de salud',
  ),
  PermisoCuidado(
    id: PermisosCuidadoConst.editarFichaSalud,
    descripcion: 'Editar ficha de salud',
  ),
  PermisoCuidado(
    id: PermisosCuidadoConst.gestionarAgenda,
    descripcion: 'Gestionar agenda',
  ),
  PermisoCuidado(
    id: PermisosCuidadoConst.registrarEventosSalud,
    descripcion: 'Registrar eventos de salud',
  ),
  PermisoCuidado(
    id: PermisosCuidadoConst.registrarHabitos,
    descripcion: 'Registrar hábitos de vida',
  ),
  PermisoCuidado(
    id: PermisosCuidadoConst.activarEmergencia,
    descripcion: 'Activar emergencia',
  ),
  PermisoCuidado(
    id: PermisosCuidadoConst.administrarEquipo,
    descripcion: 'Administrar equipo de cuidado',
  ),
];

final availablePermisosProvider = Provider<List<PermisoCuidado>>(
  (ref) => _todosCodigos,
);
// ─── Acciones mutadoras ───────────────────────────────────────────────────────

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

        ref.invalidate(careTeamAssignmentsProvider(personaCuidadaId));
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
        final repo = ref.read(careTeamRepositoryProvider);

        final nuevosPermisos = permisosActivos.map((permiso) {
          // Reusar el permiso existente si ya estaba, o crear uno nuevo.
          final existente = asignacion.permisos
              .where((p) => p.id == permiso.id)
              .firstOrNull;
          return existente ??
              PermisoCuidado(id: permiso.id, descripcion: permiso.descripcion);
        }).toList();

        final asignacionActualizada = asignacion.copyWith(
          permisos: nuevosPermisos,
        );

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
        required int asignacionId,
        required int personaCuidadaId,
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
final esContextoPropioProvider = FutureProvider.autoDispose<bool>((ref) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return false;
  final persona = await ref.watch(careTeamContextPersonaProvider.future);
  if (persona == null) return false;
  return persona.id == usuario.persona.id;
});

/// Indica si el usuario autenticado es Responsable de la persona de contexto.
final esResponsableProvider = FutureProvider.autoDispose<bool>((ref) async {
  final usuario = ref.watch(authStateProvider).valueOrNull;
  if (usuario == null) return false;
  final personaCtx = await ref.watch(careTeamContextPersonaProvider.future);
  if (personaCtx == null) return false;
  final asignaciones = await ref.watch(
    careTeamAssignmentsProvider(personaCtx.id).future,
  );
  return asignaciones.any(
    (a) =>
        a.colaborador.id == usuario.persona.id &&
        a.rol.id == RolesCuidadoConst.responsable &&
        a.estado.id == EstadosAsignacionConst.activa,
  );
});

/// True si el usuario logueado tiene el permiso [PermisosCuidadoConst.administrarEquipo]
/// sobre la persona de contexto.
final puedeAdministrarEquipoProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final usuarioAsync = ref.watch(authStateProvider);
  final usuario = usuarioAsync.valueOrNull;
  if (usuario == null) return false;

  final personaCtx = await ref.watch(careTeamContextPersonaProvider.future);
  if (personaCtx == null) return false;

  final asignaciones = await ref.watch(
    careTeamAssignmentsProvider(personaCtx.id).future,
  );

  final propia = asignaciones.where(
    (a) =>
        a.colaborador.id == usuario.persona.id &&
        a.estado.id == EstadosAsignacionConst.activa,
  );

  if (propia.isEmpty) return false;

  return propia.first.permisos.any(
    (p) => p.id == PermisosCuidadoConst.administrarEquipo,
  );
});
