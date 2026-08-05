import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../shared/confirm_dialog.dart';
import '../shared/persona_avatar.dart';

/// Tarjeta que muestra una [NotaEventoSalud] con avatar del autor, autoría y
/// contenido.
///
/// Acciones opcionales (solo se muestran cuando el usuario tiene permiso):
/// - [onEdit]: recibe el nuevo contenido de texto. Al tocar "Editar" se abre
///   un bottom sheet con el texto precargado.
/// - [onDelete]: se ejecuta tras confirmación con [ConfirmDialog].
///
/// Cuando [onEdit] y [onDelete] son null la card se comporta igual que antes
/// (solo lectura, sin fila de acciones).
class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.nota, this.onEdit, this.onDelete});

  final NotaEventoSalud nota;

  /// Callback de edición: recibe el nuevo contenido validado (no vacío).
  /// Si es null, el botón "Editar" no se muestra.
  final Future<void> Function(String nuevoContenido)? onEdit;

  /// Callback de eliminación: se ejecuta tras la confirmación del usuario.
  /// Si es null, el botón "Eliminar" no se muestra.
  final Future<void> Function()? onDelete;

  bool get _tieneAcciones => onEdit != null || onDelete != null;

  Future<void> _abrirEdicion(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _EditNoteSheet(contenidoInicial: nota.contenido, onGuardar: onEdit!),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context) {
    return ConfirmDialog.show(
      context,
      title: '¿Eliminar esta nota?',
      body:
          'Esta nota se eliminará de forma definitiva y no podrá recuperarse.',
      confirmLabel: 'Eliminar',
      icon: Icons.delete_outline,
      onConfirm: onDelete!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fechaStr = DateFormat('d MMM', 'es').format(nota.fechaHora);
    final horaStr = DateFormat('HH:mm').format(nota.fechaHora);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: context.colors.healthAccent, width: 3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D16201F),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          _tieneAcciones ? AppSpacing.xs : AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila de autoría
            Row(
              children: [
                PersonaAvatar(
                  personaId: nota.autor.id,
                  nombre: nota.autor.descripcion,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    nota.autor.descripcion,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '$fechaStr · $horaStr',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textDisabled,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Contenido
            Text(
              nota.contenido,
              style: TextStyle(
                fontSize: 14,
                color: context.colors.textPrimary,
                height: 1.5,
              ),
            ),
            // Fila de acciones (solo cuando hay callbacks)
            if (_tieneAcciones) ...[
              const SizedBox(height: AppSpacing.xs),
              Divider(height: 1, color: context.colors.outline),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    _AccionButton(
                      icon: Icons.edit_outlined,
                      label: 'Editar',
                      color: context.colors.primary,
                      onTap: () => _abrirEdicion(context),
                    ),
                  if (onDelete != null)
                    _AccionButton(
                      icon: Icons.delete_outline,
                      label: 'Eliminar',
                      color: context.colors.error,
                      onTap: () => _confirmarEliminar(context),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Botón de acción compacto ─────────────────────────────────────────────────

class _AccionButton extends StatelessWidget {
  const _AccionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

// ─── Bottom sheet de edición ──────────────────────────────────────────────────

/// Bottom sheet para editar una nota existente.
///
/// Muestra un [TextField] con el [contenidoInicial] precargado y un par de
/// botones "Cancelar" / "Guardar". Al confirmar llama [onGuardar] con el
/// contenido nuevo (ya validado como no vacío).
class _EditNoteSheet extends StatefulWidget {
  const _EditNoteSheet({
    required this.contenidoInicial,
    required this.onGuardar,
  });

  final String contenidoInicial;
  final Future<void> Function(String) onGuardar;

  @override
  State<_EditNoteSheet> createState() => _EditNoteSheetState();
}

class _EditNoteSheetState extends State<_EditNoteSheet> {
  late final TextEditingController _ctrl;
  bool _loading = false;
  String? _error;

  static const _maxChars = 500;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.contenidoInicial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final contenido = _ctrl.text.trim();
    if (contenido.isEmpty) {
      setState(() => _error = 'La nota no puede estar vacía.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onGuardar(contenido);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final charsActuales = _ctrl.text.length;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.outline,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Editar nota',
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
            minLines: 4,
            maxLines: 10,
            maxLength: _maxChars,
            textAlignVertical: TextAlignVertical.top,
            buildCounter:
                (_, {required currentLength, required isFocused, maxLength}) =>
                    null,
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(
              hintText: 'Escribí tu observación sobre este evento...',
              hintStyle: TextStyle(color: context.colors.textDisabled),
              errorText: _error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: context.colors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(
                  color: context.colors.healthAccent,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
          if (charsActuales >= 400)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$charsActuales/$_maxChars',
                style: TextStyle(
                  fontSize: 11,
                  color: charsActuales >= _maxChars
                      ? context.colors.healthAccent
                      : context.colors.textDisabled,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.colors.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: context.colors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: _loading ? null : _guardar,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.healthAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    minimumSize: const Size(0, 48),
                  ),
                  child: _loading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.onPrimary,
                          ),
                        )
                      : Text(
                          'Guardar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
