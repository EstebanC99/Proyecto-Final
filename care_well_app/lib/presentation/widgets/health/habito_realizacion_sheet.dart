import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../shared/confirm_dialog.dart';

/// Bottom sheet para marcar, editar o quitar la realización diaria de un hábito.
///
/// - Si el hábito no tiene realización hoy → flujo "Marcar como realizado".
/// - Si ya tiene realización → opciones para editar comentario o quitar marca.
abstract final class HabitoRealizacionSheet {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required HabitoVida habito,
  }) {
    if (habito.realizacion == null) {
      return _showMarcar(context, ref, habito: habito);
    } else {
      return _showOpciones(context, ref, habito: habito);
    }
  }

  // ─── Flujo: marcar como realizado ────────────────────────────────────────────

  static Future<void> _showMarcar(
    BuildContext context,
    WidgetRef ref, {
    required HabitoVida habito,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => _MarcarRealizadoSheet(habito: habito),
    );
  }

  // ─── Flujo: opciones sobre una realización existente ─────────────────────────

  static Future<void> _showOpciones(
    BuildContext context,
    WidgetRef ref, {
    required HabitoVida habito,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => _OpcionesRealizacionSheet(habito: habito),
    );
  }
}

// ─── Sheet: marcar como realizado ────────────────────────────────────────────

class _MarcarRealizadoSheet extends ConsumerStatefulWidget {
  const _MarcarRealizadoSheet({required this.habito});
  final HabitoVida habito;

  @override
  ConsumerState<_MarcarRealizadoSheet> createState() =>
      _MarcarRealizadoSheetState();
}

class _MarcarRealizadoSheetState extends ConsumerState<_MarcarRealizadoSheet> {
  final _comentarioCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    setState(() => _loading = true);
    try {
      final comentario = _comentarioCtrl.text.trim();
      await ref.read(crearRealizacionProvider)(
        habitoId: widget.habito.id,
        comentarios: comentario.isEmpty ? null : comentario,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: context.colors.error,
          ),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Marcar como realizado',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Podés agregar un comentario opcional.',
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _comentarioCtrl,
            enabled: !_loading,
            minLines: 2,
            maxLines: 4,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: 'Comentario (opcional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: FilledButton(
              onPressed: _loading ? null : _confirmar,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: _loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: context.colors.onPrimary,
                      ),
                    )
                  : Text(
                      'Marcar como realizado',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.colors.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sheet: opciones sobre realización existente ─────────────────────────────

class _OpcionesRealizacionSheet extends ConsumerWidget {
  const _OpcionesRealizacionSheet({required this.habito});
  final HabitoVida habito;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realizacion = habito.realizacion!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Realización de hoy',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            leading: Icon(Icons.edit_outlined, color: context.colors.primary),
            title: const Text('Editar comentario'),
            onTap: () {
              Navigator.of(context).pop();
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: context.colors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusXl),
                  ),
                ),
                builder: (_) => _EditarComentarioSheet(
                  habito: habito,
                  realizacion: realizacion,
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.cancel_outlined,
              color: context.colors.textSecondary,
            ),
            title: const Text('Marcar como no realizado'),
            onTap: () {
              final eliminar = ref.read(eliminarRealizacionProvider);
              Navigator.of(context).pop();
              ConfirmDialog.show(
                context,
                title: '¿Quitar la realización?',
                body: 'El hábito volverá a aparecer como Pendiente para hoy.',
                confirmLabel: 'Quitar',
                accentColor: context.colors.warning,
                icon: Icons.undo_outlined,
                onConfirm: () => eliminar(
                  habitoId: habito.id,
                  realizacionId: realizacion.id,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Sheet: editar comentario ─────────────────────────────────────────────────

class _EditarComentarioSheet extends ConsumerStatefulWidget {
  const _EditarComentarioSheet({
    required this.habito,
    required this.realizacion,
  });
  final HabitoVida habito;
  final RealizacionHabitoVida realizacion;

  @override
  ConsumerState<_EditarComentarioSheet> createState() =>
      _EditarComentarioSheetState();
}

class _EditarComentarioSheetState
    extends ConsumerState<_EditarComentarioSheet> {
  late final TextEditingController _ctrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.realizacion.comentarios ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _loading = true);
    try {
      final comentario = _ctrl.text.trim();
      await ref.read(modificarRealizacionProvider)(
        habitoId: widget.habito.id,
        realizacionId: widget.realizacion.id,
        comentarios: comentario.isEmpty ? null : comentario,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: context.colors.error,
          ),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Editar comentario',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _ctrl,
            enabled: !_loading,
            minLines: 2,
            maxLines: 4,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: 'Comentario (opcional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: FilledButton(
              onPressed: _loading ? null : _guardar,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: _loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: context.colors.onPrimary,
                      ),
                    )
                  : Text(
                      'Guardar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.colors.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
