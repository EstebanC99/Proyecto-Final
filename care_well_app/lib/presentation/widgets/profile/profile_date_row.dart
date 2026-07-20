import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Fila de dato de perfil para una fecha, con edición mediante [showDatePicker].
///
/// Análoga a `ProfileDataRow` pero especializada para fechas: en lugar de un
/// campo de texto, al tocar el ícono lápiz abre el selector de fecha nativo.
/// Muestra un spinner mientras persiste el cambio.
class ProfileDateRow extends StatefulWidget {
  const ProfileDateRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onSave,
  });

  /// Ícono del campo.
  final IconData icon;

  /// Etiqueta descriptiva (ej: "Fecha de nacimiento").
  final String label;

  /// Valor actual de la fecha.
  final DateTime value;

  /// Callback invocado al elegir una fecha distinta. Recibe la nueva fecha.
  /// Puede lanzar excepción; en ese caso se muestra el error inline.
  final Future<void> Function(DateTime)? onSave;

  @override
  State<ProfileDateRow> createState() => _ProfileDateRowState();
}

class _ProfileDateRowState extends State<ProfileDateRow> {
  bool _guardando = false;
  String? _errorText;

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value,
      firstDate: DateTime(1900),
      lastDate: hoy,
    );
    if (picked == null || !mounted) return;

    // Sin cambios: no persistir.
    final actual = widget.value;
    if (picked.year == actual.year &&
        picked.month == actual.month &&
        picked.day == actual.day) {
      return;
    }

    setState(() {
      _guardando = true;
      _errorText = null;
    });
    try {
      await widget.onSave?.call(picked);
      if (mounted) setState(() => _guardando = false);
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
    final fechaStr = DateFormat('dd/MM/yyyy').format(widget.value);

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
          child: Row(
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
                      fechaStr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _errorText!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
                        onPressed: _seleccionarFecha,
                        icon: const Icon(Icons.edit, size: 20),
                        color: AppColors.primary,
                        tooltip: 'Editar ${widget.label}',
                        padding: EdgeInsets.zero,
                      ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.outline),
      ],
    );
  }
}
