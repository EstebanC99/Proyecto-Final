import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../shared/icon_square.dart';

/// Fila de dato de perfil para una fecha, con edición mediante [showDatePicker].
///
/// Análoga a `ProfileDataRow` pero especializada para fechas: en lugar de un
/// campo de texto, al tocar el ícono lápiz abre el selector de fecha nativo.
/// Muestra un spinner mientras persiste el cambio.
///
/// Está pensada para vivir dentro de un `CardGroup`: no pinta fondo propio ni
/// dibuja separadores, eso lo aporta la tarjeta que la contiene.
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

    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconSquare(icon: widget.icon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fechaStr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _errorText!,
                    style: TextStyle(fontSize: 12, color: context.colors.error),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: AppSpacing.minTapTarget,
            height: AppSpacing.minTapTarget,
            child: _guardando
                ? Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: context.colors.primary,
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: _seleccionarFecha,
                    icon: const Icon(Icons.edit, size: 20),
                    color: context.colors.primary,
                    tooltip: 'Editar ${widget.label}',
                    padding: EdgeInsets.zero,
                  ),
          ),
        ],
      ),
    );
  }
}
