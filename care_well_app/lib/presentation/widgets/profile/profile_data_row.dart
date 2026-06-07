import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../shared/app_text_field.dart';

/// Fila de dato de perfil con soporte para edición inline campo a campo.
///
/// Modos:
/// - **Lectura:** ícono + label + valor + (si [editable]) ícono lápiz a la derecha.
/// - **Edición:** ícono + [AppTextField] precargado + botón check + botón X.
/// - **Guardando:** igual que edición pero campo deshabilitado y spinner en lugar del check.
///
/// El campo de edición solo se activa al tocar el ícono lápiz (no el resto de la fila).
class ProfileDataRow extends StatefulWidget {
  const ProfileDataRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.editable = false,
    this.onSave,
    this.keyboardType,
    this.validator,
  });

  /// Ícono del campo (ej: [Icons.email]).
  final IconData icon;

  /// Etiqueta descriptiva (ej: "Email").
  final String label;

  /// Valor actual del campo.
  final String value;

  /// Si es `true` se muestra el ícono lápiz y se permite edición inline.
  final bool editable;

  /// Callback invocado al confirmar el guardado. Recibe el nuevo valor.
  /// Puede lanzar excepción; en ese caso se muestra el error inline.
  final Future<void> Function(String)? onSave;

  /// Tipo de teclado para el campo de edición.
  final TextInputType? keyboardType;

  /// Función de validación. Retorna null si válido, String con error si no.
  final String? Function(String?)? validator;

  @override
  State<ProfileDataRow> createState() => _ProfileDataRowState();
}

class _ProfileDataRowState extends State<ProfileDataRow> {
  bool _editando = false;
  bool _guardando = false;
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(ProfileDataRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sincronizar el controller si el valor externo cambió y no estamos editando.
    if (!_editando && oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _activarEdicion() {
    setState(() {
      _editando = true;
      _errorText = null;
      _controller.text = widget.value;
    });
  }

  void _cancelar() {
    setState(() {
      _editando = false;
      _errorText = null;
      _controller.text = widget.value;
    });
  }

  Future<void> _confirmar() async {
    final nuevoValor = _controller.text.trim();

    // Validar
    if (widget.validator != null) {
      final error = widget.validator!(nuevoValor);
      if (error != null) {
        setState(() => _errorText = error);
        return;
      }
    }

    // No cambió
    if (nuevoValor == widget.value.trim()) {
      _cancelar();
      return;
    }

    setState(() {
      _guardando = true;
      _errorText = null;
    });

    try {
      await widget.onSave?.call(nuevoValor);
      if (mounted) {
        setState(() {
          _editando = false;
          _guardando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _errorText = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          color: AppColors.surface,
          child: _editando ? _buildEditing() : _buildReading(),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.outline),
      ],
    );
  }

  Widget _buildReading() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(widget.icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.value.isNotEmpty ? widget.value : '—',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (widget.editable)
          SizedBox(
            width: AppSpacing.minTapTarget,
            height: AppSpacing.minTapTarget,
            child: IconButton(
              onPressed: _activarEdicion,
              icon: const Icon(Icons.edit, size: 20),
              color: AppColors.primary,
              tooltip: 'Editar ${widget.label}',
              padding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }

  Widget _buildEditing() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child: Icon(widget.icon, size: 20, color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppTextField(
            label: widget.label,
            controller: _controller,
            enabled: !_guardando,
            keyboardType: widget.keyboardType,
            errorText: _errorText,
            autocorrect: false,
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        // Botón cancelar
        SizedBox(
          width: AppSpacing.minTapTarget,
          height: AppSpacing.minTapTarget,
          child: IconButton(
            onPressed: _guardando ? null : _cancelar,
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Cancelar',
            padding: EdgeInsets.zero,
          ),
        ),
        // Botón confirmar / spinner
        SizedBox(
          width: AppSpacing.minTapTarget,
          height: AppSpacing.minTapTarget,
          child: _guardando
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: _confirmar,
                  icon: const Icon(Icons.check, size: 20),
                  color: AppColors.primary,
                  tooltip: 'Guardar',
                  padding: EdgeInsets.zero,
                ),
        ),
      ],
    );
  }
}
