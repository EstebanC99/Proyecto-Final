import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';

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
  // Lista estática de tipos de hábito disponibles (reemplaza TipoHabito.values).
  static final _tiposHabito = [
    TipoHabitoVida(
      id: TiposHabitoConst.actividadFisica,
      descripcion: 'Actividad física',
    ),
    TipoHabitoVida(id: TiposHabitoConst.alimentacion, descripcion: 'Alimentación'),
    TipoHabitoVida(id: TiposHabitoConst.sueno, descripcion: 'Sueño'),
    TipoHabitoVida(id: TiposHabitoConst.hidratacion, descripcion: 'Hidratación'),
    TipoHabitoVida(id: TiposHabitoConst.otro, descripcion: 'Bienestar'),
  ];

  TipoHabitoVida _tipo = TipoHabitoVida(
    id: TiposHabitoConst.alimentacion,
    descripcion: 'Alimentación',
  );
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
          _tipo = habito.tipo;
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
    switch (_tipo.id) {
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
    if (desc.isEmpty) return;
    setState(() => _loading = true);
    try {
      if (_esEdicion) {
        await ref.read(modificarHabitoProvider)(
          habitoId: widget.habitId!,
          tipoId: _tipo.id,
          descripcion: desc,
        );
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hábito actualizado correctamente')),
          );
        }
      } else {
        await ref.read(crearHabitoProvider)(
          tipoId: _tipo.id,
          descripcion: desc,
        );
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tiposHabito.map((t) {
                  final selected = t.id == _tipo.id;
                  final label = _labelTipo(t);
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => setState(() {
                        _tipo = t;
                        _descripcionCtrl.clear();
                      }),
                      selectedColor: AppColors.habitsAccent,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
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
                onPressed: (_loading || !tieneDescripcion) ? null : _guardar,
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

  static String _labelTipo(TipoHabitoVida tipo) => tipo.descripcion;
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
