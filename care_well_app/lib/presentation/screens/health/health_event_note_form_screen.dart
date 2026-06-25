import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Formulario para agregar una nota a un evento de salud (US-32).
class HealthEventNoteFormScreen extends ConsumerStatefulWidget {
  const HealthEventNoteFormScreen({super.key, required this.eventoId});

  final int eventoId;

  @override
  ConsumerState<HealthEventNoteFormScreen> createState() =>
      _HealthEventNoteFormScreenState();
}

class _HealthEventNoteFormScreenState
    extends ConsumerState<HealthEventNoteFormScreen> {
  final _contenidoCtrl = TextEditingController();
  bool _loading = false;
  String? _errorInline;

  static const _maxChars = 500;
  static const _contadorThreshold = 400;

  @override
  void dispose() {
    _contenidoCtrl.dispose();
    super.dispose();
  }

  bool get _tieneContenido => _contenidoCtrl.text.trim().isNotEmpty;

  Future<bool> _shouldPop() async {
    if (!_tieneContenido) return true;
    final confirmo = await ConfirmDialog.show(
      context,
      title: 'Tenés cambios sin guardar',
      body: '¿Salir de todas formas?',
      confirmLabel: 'Salir',
      onConfirm: () async {},
      icon: Icons.warning_amber_rounded,
    );
    return confirmo;
  }

  Future<void> _guardar() async {
    final contenido = _contenidoCtrl.text.trim();
    if (contenido.isEmpty) {
      setState(() => _errorInline = 'La nota no puede estar vacía.');
      return;
    }
    setState(() {
      _loading = true;
      _errorInline = null;
    });
    try {
      await ref.read(crearNotaEventoProvider)(
        eventoSaludId: widget.eventoId,
        contenido: contenido,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nota guardada')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo guardar la nota.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final charsUsados = _contenidoCtrl.text.length;
    final mostrarContador = charsUsados >= _contadorThreshold;
    final countColor = charsUsados >= _maxChars
        ? AppColors.healthAccent
        : AppColors.textDisabled;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _shouldPop();
        if (ok && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Nueva nota'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label campo nota
              Row(
                children: [
                  const Text(
                    'Nota',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.healthAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Textarea
              TextField(
                controller: _contenidoCtrl,
                enabled: !_loading,
                minLines: 5,
                maxLines: 12,
                maxLength: _maxChars,
                textAlignVertical: TextAlignVertical.top,
                buildCounter:
                    (
                      _, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null, // contador manual
                onChanged: (_) => setState(() => _errorInline = null),
                decoration: InputDecoration(
                  hintText: 'Escribí tu observación sobre este evento...',
                  hintStyle: const TextStyle(color: AppColors.textDisabled),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide(
                      color: _errorInline != null
                          ? AppColors.healthAccent
                          : AppColors.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(
                      color: AppColors.healthAccent,
                      width: 2,
                    ),
                  ),
                  errorText: _errorInline,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              // Contador
              if (mostrarContador)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$charsUsados/$_maxChars',
                    style: TextStyle(fontSize: 11, color: countColor),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: FilledButton(
                  onPressed: _loading ? null : _guardar,
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
                          'Guardar nota',
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
      ),
    );
  }
}
