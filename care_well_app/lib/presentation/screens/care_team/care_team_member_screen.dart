import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// US-18/19/21/22 · Modificación de permisos y baja de miembro del equipo.
///
/// Carga la asignación por [memberId]. Si no existe, muestra error inline sin crash.
/// Permite editar permisos y confirmar la baja del miembro.
class CareTeamMemberScreen extends ConsumerStatefulWidget {
  const CareTeamMemberScreen({super.key, required this.memberId});

  final int memberId;

  @override
  ConsumerState<CareTeamMemberScreen> createState() =>
      _CareTeamMemberScreenState();
}

class _CareTeamMemberScreenState extends ConsumerState<CareTeamMemberScreen> {
  /// Mapa de permisos por id: true = activo, false = inactivo.
  Map<int, bool>? _permisos;
  Map<int, bool>? _permisosIniciales;
  bool _guardando = false;

  bool get _hayCambios {
    if (_permisos == null || _permisosIniciales == null) return false;
    for (final id in _permisos!.keys) {
      if (_permisos![id] != _permisosIniciales![id]) return true;
    }
    return false;
  }

  void _inicializarPermisos(
    AsignacionCuidado asignacion,
    List<CodigoPermiso> todosLosCodigos,
  ) {
    if (_permisos != null) return; // ya inicializado
    final idsActivos = asignacion.permisos.map((p) => p.codigo.id).toSet();
    _permisos = {
      for (final c in todosLosCodigos) c.id: idsActivos.contains(c.id),
    };
    _permisosIniciales = Map.from(_permisos!);
  }

  Future<void> _guardarCambios(
    AsignacionCuidado asignacion,
    List<CodigoPermiso> todosLosCodigos,
  ) async {
    if (_permisos == null) return;
    setState(() => _guardando = true);

    try {
      final actualizar = ref.read(actualizarPermisosProvider);
      final permisosActivos = todosLosCodigos
          .where((c) => _permisos![c.id] == true)
          .toList();
      await actualizar(
        asignacion: asignacion,
        permisosActivos: permisosActivos,
      );
      if (!mounted) return;
      setState(() {
        _permisosIniciales = Map.from(_permisos!);
        _guardando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permisos actualizados.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmarBaja(AsignacionCuidado asignacion) async {
    final nombre = asignacion.personaColaborador.nombreCompleto;
    final confirmo = await ConfirmDialog.show(
      context,
      title: '¿Quitar a $nombre del equipo?',
      body:
          '$nombre perderá el acceso a los datos de '
          '${asignacion.personaCuidada.nombre} y ya no podrá gestionar su '
          'cuidado. Esta acción se puede revertir agregándolo nuevamente.',
      confirmLabel: 'Quitar del equipo',
      icon: Icons.person_remove_outlined,
      onConfirm: () async {
        final eliminar = ref.read(eliminarMiembroProvider);
        await eliminar(
          asignacionId: asignacion.id,
          personaCuidadaId: asignacion.personaCuidada.id,
        );
      },
    );
    if (confirmo && mounted) {
      context.pop();
    }
  }

  Future<bool> _onPopScope() async {
    if (!_hayCambios) return true;
    final descarta = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Descartás los cambios?'),
        content: const Text(
          'Tenés cambios de permisos sin guardar. '
          'Si salís ahora, se perderán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Seguir editando'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return descarta ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final asignacionAsync = ref.watch(assignmentByIdProvider(widget.memberId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final puede = await _onPopScope();
        if (puede && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: asignacionAsync.when(
            loading: () => const Text('Miembro del equipo'),
            error: (e, st) => const Text('Miembro del equipo'),
            data: (a) =>
                Text(a?.personaColaborador.nombre ?? 'Miembro del equipo'),
          ),
          actions: [
            asignacionAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
              data: (a) => a != null
                  ? IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      tooltip: 'Quitar del equipo',
                      onPressed: () => _confirmarBaja(a),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        body: asignacionAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: InlineErrorBanner(message: 'No se pudo cargar el miembro.'),
          ),
          data: (asignacion) {
            if (asignacion == null) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: InlineErrorBanner(
                  message:
                      'El miembro "${widget.memberId}" no existe o fue dado de baja.',
                ),
              );
            }

            final todosLosCodigos = ref.watch(availablePermisosProvider);

            // Inicializar permisos en el primer render.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_permisos == null) {
                setState(
                  () => _inicializarPermisos(asignacion, todosLosCodigos),
                );
              }
            });

            if (_permisos == null) {
              _inicializarPermisos(asignacion, todosLosCodigos);
            }

            final personaCuidada = asignacion.personaCuidada;

            return Column(
              children: [
                // Header del miembro
                Container(
                  color: AppColors.surface,
                  child: MemberCard(
                    asignacion: asignacion,
                    isCurrentUser: false,
                    onTap: () {},
                    showChevron: false,
                  ),
                ),
                const Divider(height: 1, color: AppColors.outline),

                // Sección permisos
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título sección
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.sm,
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              children: [
                                const TextSpan(text: 'Permisos sobre '),
                                TextSpan(
                                  text: personaCuidada.nombreCompleto,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Lista de permisos
                        Container(
                          color: AppColors.surface,
                          child: Column(
                            children: todosLosCodigos.asMap().entries.map((
                              entry,
                            ) {
                              final i = entry.key;
                              final codigo = entry.value;
                              return Column(
                                children: [
                                  PermissionToggleRow(
                                    label: labelDePermiso(codigo),
                                    value: _permisos?[codigo.id] ?? false,
                                    onChanged: (v) => setState(
                                      () => _permisos![codigo.id] = v,
                                    ),
                                  ),
                                  if (i < todosLosCodigos.length - 1)
                                    const Divider(
                                      height: 1,
                                      thickness: 1,
                                      indent: AppSpacing.lg,
                                      endIndent: AppSpacing.lg,
                                      color: AppColors.surfaceVariant,
                                    ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botón guardar
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Guardar cambios',
                      isLoading: _guardando,
                      onPressed: _hayCambios
                          ? () => _guardarCambios(asignacion, todosLosCodigos)
                          : null,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
