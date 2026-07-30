import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Formulario para registrar o editar un hábito de vida (US-28b y US-28c).
///
/// En modo creación ([habitId] es null) usa [crearHabitoProvider].
/// En modo edición ([habitId] no es null) precarga el hábito existente
/// y usa [modificarHabitoProvider].
class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habitId});

  /// ID del hábito a editar. Null indica modo creación.
  final int? habitId;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  /// Id del tipo seleccionado. `null` hasta que carga el catálogo.
  int? _tipoId;
  final _descripcionCtrl = TextEditingController();
  bool _loading = false;
  bool _precargado = false;

  bool get _esEdicion => widget.habitId != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _precargar());
    }
  }

  /// Precarga los datos del hábito cuando se está en modo edición.
  Future<void> _precargar() async {
    if (_precargado) return;
    try {
      final habito = await ref.read(habitoByIdProvider(widget.habitId!).future);
      if (habito != null && mounted) {
        setState(() {
          _tipoId = habito.tipo.id;
          _descripcionCtrl.text = habito.descripcion;
          _precargado = true;
        });
      }
    } catch (_) {
      // Si falla la carga, el usuario puede completar el formulario manualmente.
    }
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  String get _placeholder {
    switch (_tipoId) {
      case TiposHabitoConst.actividadFisica:
        return 'Ej. Caminata de 30 minutos por el parque.';
      case TiposHabitoConst.alimentacion:
        return 'Ej. Desayuno con avena, frutas y yogur.';
      case TiposHabitoConst.sueno:
        return 'Ej. Durmió 7 horas con pocas interrupciones.';
      case TiposHabitoConst.hidratacion:
        return 'Ej. Tomó 1,5 litros de agua durante el día.';
      default:
        return 'Describí el hábito registrado...';
    }
  }

  Future<void> _guardar() async {
    final desc = _descripcionCtrl.text.trim();
    final tipoId = _tipoId;
    if (desc.isEmpty || tipoId == null) return;
    setState(() => _loading = true);
    try {
      if (_esEdicion) {
        await ref.read(modificarHabitoProvider)(
          habitoId: widget.habitId!,
          tipoId: tipoId,
          descripcion: desc,
        );
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hábito actualizado correctamente')),
          );
        }
      } else {
        await ref.read(crearHabitoProvider)(tipoId: tipoId, descripcion: desc);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hábito registrado correctamente')),
          );
        }
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
    final tieneDescripcion = _descripcionCtrl.text.trim().isNotEmpty;
    final tiposAsync = ref.watch(tiposHabitoVidaProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar hábito' : 'Nuevo hábito'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categoría
            const _SectionLabel('Categoría'),
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
                message: 'No se pudieron cargar los tipos de hábito. $err',
              ),
              data: (tipos) {
                if (tipos.isEmpty) {
                  return const Text(
                    'No hay tipos de hábito disponibles.',
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
                              : (_) => setState(() {
                                  _tipoId = t.id;
                                  _descripcionCtrl.clear();
                                }),
                          selectedColor: AppColors.habitsAccent,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
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
              maxLines: 6,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _placeholder,
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
            const SizedBox(height: AppSpacing.xxxl),

            // Botón registrar
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: FilledButton(
                onPressed: (_loading || !tieneDescripcion || _tipoId == null)
                    ? null
                    : _guardar,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.habitsAccent,
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
                    : Text(
                        _esEdicion ? 'Guardar cambios' : 'Registrar',
                        style: const TextStyle(
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
