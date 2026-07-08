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
  // El dial siempre muestra un valor; arranca en "Regular" (centro de la
  // escala). El registro queda deshabilitado hasta la primera interacción.
  int _level = EstadosAnimoConst.regular;
  bool _hasInteracted = false;
  final _observacionesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    setState(() => _loading = true);
    try {
      await ref.read(registrarAnimoProvider)(
        estadoAnimoId: _level,
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
    final personaAsync = ref.watch(personaVisualizacionSeleccionadaProvider);
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector de persona de contexto
          personaAsync.when(
            data: (persona) => persona != null
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: ContextSelector(),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtítulo
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      '¿Cómo se siente $nombrePersona hoy?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // Selector tipo dial (carrusel de niveles)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xl,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: MoodDialSelector(
                      selectedLevel: _level,
                      onChanged: (level) => setState(() {
                        _level = level;
                        _hasInteracted = true;
                      }),
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
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Botón registrar: outlined violeta hasta la 1ª interacción,
                  // luego pasa a filled y queda habilitado.
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.buttonHeight,
                    child: _hasInteracted
                        ? FilledButton(
                            onPressed: _loading ? null : _registrar,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.moodAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
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
                          )
                        : OutlinedButton(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.moodAccent,
                                width: 2,
                              ),
                              disabledForegroundColor: AppColors.moodAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Registrar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  if (!_hasInteracted)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.sm),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Tocá las flechas para elegir un estado y confirmar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
