import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
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
                  child: Text(
                    'Ver historial',
                    // El SnackBar se pinta sobre `inverseSurface`, que se
                    // invierte con el tema: el texto no puede ser blanco fijo.
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
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
            backgroundColor: context.colors.error,
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
    final nombrePersona = personaAsync.value?.nombre ?? 'la persona a cargo';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const ContextAppBar(eyebrow: 'Estado de ánimo'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
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
                      color: context.colors.surface,
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
                  Text(
                    'Observación',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textSecondary,
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
                      hintStyle: TextStyle(color: context.colors.textDisabled),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(top: 14),
                        child: Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: context.colors.textDisabled,
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
                              backgroundColor: context.colors.moodAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
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
                              side: BorderSide(
                                color: context.colors.moodAccent,
                                width: 2,
                              ),
                              disabledForegroundColor:
                                  context.colors.moodAccent,
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
                    Padding(
                      padding: EdgeInsets.only(top: AppSpacing.sm),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Tocá las flechas para elegir un estado y confirmar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textSecondary,
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
