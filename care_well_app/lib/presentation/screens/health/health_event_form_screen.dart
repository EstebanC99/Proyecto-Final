import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';

/// Formulario para registrar un nuevo evento de salud (US-30).
class HealthEventFormScreen extends ConsumerStatefulWidget {
  const HealthEventFormScreen({super.key, this.eventId});

  /// Si no es null, se muestra como edición (futuro MVP).
  final String? eventId;

  @override
  ConsumerState<HealthEventFormScreen> createState() =>
      _HealthEventFormScreenState();
}

class _HealthEventFormScreenState extends ConsumerState<HealthEventFormScreen> {
  TipoEventoSalud _tipo = TipoEventoSalud.citaMedica;
  final _descripcionCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();
  bool _loading = false;

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

  Future<void> _guardar() async {
    final desc = _descripcionCtrl.text.trim();
    if (desc.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(crearEventoSaludProvider)(
        tipo: _tipo,
        descripcion: desc,
        fecha: _fecha,
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
            content: const Text(
              'No se pudo registrar el evento. Intentá de nuevo.',
            ),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TipoEventoSalud.values.map((t) {
                  final selected = t == _tipo;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(_labelTipo(t)),
                      selected: selected,
                      onSelected: (_) => setState(() => _tipo = t),
                      selectedColor: AppColors.healthAccent,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
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

            // Fecha
            const _SectionLabel('Fecha *'),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _loading ? null : _elegirFecha,
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
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Botón registrar
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: FilledButton(
                onPressed: (_loading || !tieneDesc) ? null : _guardar,
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

  static String _labelTipo(TipoEventoSalud tipo) {
    switch (tipo) {
      case TipoEventoSalud.citaMedica:
        return 'Cita médica';
      case TipoEventoSalud.hospitalizacion:
        return 'Hospitalización';
      case TipoEventoSalud.medicacion:
        return 'Medicación';
      case TipoEventoSalud.cirugia:
        return 'Cirugía';
      case TipoEventoSalud.tratamiento:
        return 'Tratamiento';
      case TipoEventoSalud.bienestar:
        return 'Bienestar';
      case TipoEventoSalud.sintoma:
        return 'Síntoma';
      case TipoEventoSalud.diagnostico:
        return 'Diagnóstico';
      case TipoEventoSalud.vacuna:
        return 'Vacuna';
      case TipoEventoSalud.otro:
        return 'Otro';
    }
  }
}

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
