import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de registro del estado de ánimo (US-31).
class MoodFormScreen extends ConsumerStatefulWidget {
  const MoodFormScreen({super.key});

  @override
  ConsumerState<MoodFormScreen> createState() => _MoodFormScreenState();
}

class _MoodFormScreenState extends ConsumerState<MoodFormScreen> {
  int? _selectedLevel;
  final _observacionesCtrl = TextEditingController();
  bool _loading = false;
  String? _moodError;

  @override
  void dispose() {
    _observacionesCtrl.dispose();
    super.dispose();
  }

  /// Convierte un nivel entero (1–5) a la entidad catálogo [EstadoAnimo].
  EstadoAnimo _levelToEstado(int level) {
    switch (level) {
      case EstadosAnimoConst.muyMal:
        return EstadoAnimo(
          id: EstadosAnimoConst.muyMal,
          descripcion: 'Muy mal',
        );
      case EstadosAnimoConst.mal:
        return EstadoAnimo(id: EstadosAnimoConst.mal, descripcion: 'Mal');
      case EstadosAnimoConst.regular:
        return EstadoAnimo(
          id: EstadosAnimoConst.regular,
          descripcion: 'Regular',
        );
      case EstadosAnimoConst.bien:
        return EstadoAnimo(id: EstadosAnimoConst.bien, descripcion: 'Bien');
      case EstadosAnimoConst.muyBien:
        return EstadoAnimo(
          id: EstadosAnimoConst.muyBien,
          descripcion: 'Muy bien',
        );
      default:
        return EstadoAnimo(
          id: EstadosAnimoConst.regular,
          descripcion: 'Regular',
        );
    }
  }

  Future<void> _registrar() async {
    if (_selectedLevel == null) {
      setState(() => _moodError = 'Seleccioná un estado de ánimo.');
      return;
    }
    setState(() {
      _loading = true;
      _moodError = null;
    });
    try {
      await ref.read(registrarAnimoProvider)(
        estado: _levelToEstado(_selectedLevel!),
        observaciones: _observacionesCtrl.text.trim().isEmpty
            ? null
            : _observacionesCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estado de ánimo registrado'),
                TextButton(
                  onPressed: () =>
                      context.pushNamed(AppRoutes.healthMoodHistoryName),
                  child: const Text(
                    'Ver historial',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo registrar. Intentá de nuevo.'),
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
    final personaAsync = ref.watch(healthPersonaContextProvider);
    final nombrePersona =
        personaAsync.valueOrNull?.nombre ?? 'la persona a cargo';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Estado de ánimo'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtítulo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                '¿Cómo se siente $nombrePersona hoy?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // MoodPicker
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: MoodPicker(
                selectedLevel: _selectedLevel,
                onChanged: (level) => setState(() {
                  _selectedLevel = level;
                  _moodError = null;
                }),
              ),
            ),
            if (_moodError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _moodError!,
                  style: const TextStyle(fontSize: 12, color: AppColors.error),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),

            // Observación (opcional)
            const Text(
              'Observación',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _observacionesCtrl,
              enabled: !_loading,
              minLines: 3,
              maxLines: 6,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Ej. Estuvo tranquila, durmió bien',
                hintStyle: const TextStyle(color: AppColors.textDisabled),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: AppColors.textDisabled,
                  ),
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
            const SizedBox(height: AppSpacing.xxxl),

            // Botón registrar
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: FilledButton(
                onPressed: _loading ? null : _registrar,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.moodAccent,
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
                        'Registrar',
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
