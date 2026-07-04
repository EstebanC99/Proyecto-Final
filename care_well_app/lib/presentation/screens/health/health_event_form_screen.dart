import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Formulario para registrar un nuevo evento de salud (US-30).
///
/// El tipo de evento se selecciona desde el catálogo compartido con la agenda
/// ([tiposEventoProvider]). Un evento de salud es algo que ya ocurrió, por lo que
/// no se admiten fechas ni horas futuras.
class HealthEventFormScreen extends ConsumerStatefulWidget {
  const HealthEventFormScreen({super.key, this.eventId});

  /// Si no es null, se muestra como edición (futuro MVP).
  final int? eventId;

  @override
  ConsumerState<HealthEventFormScreen> createState() =>
      _HealthEventFormScreenState();
}

class _HealthEventFormScreenState extends ConsumerState<HealthEventFormScreen> {
  /// Id del tipo seleccionado. `null` hasta que carga el catálogo.
  int? _tipoId;
  final _descripcionCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();
  bool _loading = false;

  /// Combina [_fecha] y [_hora] en un único [DateTime] con horas y minutos.
  DateTime get _fechaHora =>
      DateTime(_fecha.year, _fecha.month, _fecha.day, _hora.hour, _hora.minute);

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _elegirHora() async {
    final picked = await showTimePicker(context: context, initialTime: _hora);
    if (picked == null) return;
    final ahora = DateTime.now();
    final esHoy =
        _fecha.year == ahora.year &&
        _fecha.month == ahora.month &&
        _fecha.day == ahora.day;
    final horaFutura =
        esHoy &&
        (picked.hour > ahora.hour ||
            (picked.hour == ahora.hour && picked.minute > ahora.minute));
    setState(() => _hora = horaFutura ? TimeOfDay.fromDateTime(ahora) : picked);
  }

  Future<void> _guardar() async {
    final desc = _descripcionCtrl.text.trim();
    final tipoId = _tipoId;
    if (desc.isEmpty || tipoId == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(crearEventoSaludProvider)(
        tipoId: tipoId,
        descripcion: desc,
        fechaHora: _fechaHora,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento registrado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tieneDesc = _descripcionCtrl.text.trim().isNotEmpty;
    final tiposAsync = ref.watch(tiposEventoProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.eventId == null
              ? 'Nuevo evento de salud'
              : 'Editar evento de salud',
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de evento
            const _SectionLabel('Tipo de evento *'),
            const SizedBox(height: AppSpacing.sm),
            tiposAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
              error: (err, _) => InlineErrorBanner(
                message: 'No se pudieron cargar los tipos de evento. $err',
              ),
              data: (tipos) {
                if (tipos.isEmpty) {
                  return const Text(
                    'No hay tipos de evento disponibles.',
                    style: TextStyle(color: AppColors.textSecondary),
                  );
                }
                // Selección por defecto: primer tipo del catálogo.
                _tipoId ??= tipos.first.id;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: tipos.map((t) {
                      final selected = t.id == _tipoId;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(t.descripcion),
                          selected: selected,
                          onSelected: _loading
                              ? null
                              : (_) => setState(() => _tipoId = t.id),
                          selectedColor: AppColors.healthAccent,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Descripción
            const _SectionLabel('Descripción *'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descripcionCtrl,
              enabled: !_loading,
              minLines: 3,
              maxLines: 8,
              maxLength: 500,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Describí el evento de salud...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Icon(Icons.description_outlined),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 48),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Fecha y hora — en fila, mismo estilo visual
            Row(
              children: [
                Expanded(
                  child: _PickerField(
                    label: 'Fecha *',
                    icon: Icons.calendar_today_outlined,
                    value: '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                    onTap: _loading ? null : _elegirFecha,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _PickerField(
                    label: 'Hora *',
                    icon: Icons.schedule_outlined,
                    value: _hora.format(context),
                    onTap: _loading ? null : _elegirHora,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Botón registrar
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: FilledButton(
                onPressed: (_loading || !tieneDesc || _tipoId == null)
                    ? null
                    : _guardar,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.healthAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Registrar evento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Campo picker de solo lectura que abre un diálogo al tocarlo.
///
/// Mismo estilo visual que el `_PickerField` de `agenda_event_screen.dart`:
/// borde outline, ícono a la izquierda, texto de valor y etiqueta de sección
/// encima del campo.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              color: AppColors.surface,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
