import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_palette.dart';
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
  /// Tope de caracteres de la descripción. Es un límite de UI: mantiene el
  /// texto legible en las tarjetas y en el resumen diario.
  static const _maxDescripcion = 500;

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
    final tieneDescripcion = _descripcionCtrl.text.trim().isNotEmpty;
    final tiposAsync = ref.watch(tiposHabitoVidaProvider);

    // `animate: false` de animate_do no desactiva la animación: deja el
    // controller en 0, o sea el hijo invisible. Con las animaciones apagadas
    // hay que saltear el wrapper, no configurarlo.
    final sinAnimacion = MediaQuery.disableAnimationsOf(context);
    Widget animado(Widget child, int delayMs) => sinAnimacion
        ? child
        : FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: Duration(milliseconds: delayMs),
            from: 12,
            child: child,
          );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: ContextAppBar(
        eyebrow: _esEdicion ? 'Editar hábito' : 'Nuevo hábito',
        // El formulario muestra a quién se le registra, pero no deja cambiar
        // de persona con los datos a medio cargar.
        seleccionable: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            animado(_categoria(tiposAsync), 0),
            animado(_descripcion(), 50),
          ],
        ),
      ),
      bottomNavigationBar: animado(_barraInferior(tieneDescripcion), 100),
    );
  }

  /// Bloque de selección de categoría del hábito.
  Widget _categoria(AsyncValue<List<TipoHabitoVida>> tiposAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sin marca de obligatorio: la categoría siempre viene preseleccionada.
        const SectionLabel(
          text: 'Categoría',
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
        ),
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
              return Text(
                'No hay tipos de hábito disponibles.',
                style: TextStyle(color: context.colors.textSecondary),
              );
            }
            // El orden lo define el catálogo, no el backend: así "Otro" (el id
            // más alto) queda siempre al final.
            final ordenados = [...tipos]..sort((a, b) => a.id.compareTo(b.id));

            // Selección por defecto: el primer tile de la grilla, para que lo
            // preseleccionado y lo que se ve arriba a la izquierda coincidan.
            _tipoId ??= ordenados.first.id;

            return TypeTileGrid(
              options: [
                for (final tipo in ordenados)
                  TypeTileOption(
                    id: tipo.id,
                    label: tipo.descripcion,
                    icon: TipoHabitoTheme.iconFor(tipo.id),
                    accent: TipoHabitoTheme.accentFor(context, tipo.id),
                    container: TipoHabitoTheme.containerFor(context, tipo.id),
                  ),
              ],
              selectedId: _tipoId,
              // Cambiar de categoría NO toca la descripción: el hint sólo se
              // ve con el campo vacío, así que no hay nada que "destrabar"
              // borrando lo que el usuario ya escribió.
              onChanged: (id) => setState(() => _tipoId = id),
              enabled: !_loading,
            );
          },
        ),
      ],
    );
  }

  /// Bloque de descripción, con contador propio de caracteres.
  Widget _descripcion() {
    final usados = _descripcionCtrl.text.characters.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(
          text: 'Descripción',
          required: true,
          padding: EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
        ),
        TextFormField(
          controller: _descripcionCtrl,
          enabled: !_loading,
          minLines: 3,
          maxLines: 6,
          maxLength: _maxDescripcion,
          // El contador nativo se apaga para pintar uno propio, alineado con
          // el resto de la tipografía del formulario.
          buildCounter:
              (
                _, {
                required int currentLength,
                required bool isFocused,
                int? maxLength,
              }) => null,
          textAlignVertical: TextAlignVertical.top,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: _placeholder,
            filled: true,
            fillColor: context.colors.surface,
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
            border: _bordeCampo(context.colors.outline),
            enabledBorder: _bordeCampo(context.colors.outline),
            disabledBorder: _bordeCampo(context.colors.outline),
            focusedBorder: _bordeCampo(context.colors.habitsAccent, ancho: 1.5),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$usados / $_maxDescripcion',
            style: TextStyle(
              fontSize: 11.5,
              color: context.colors.textDisabled,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _bordeCampo(Color color, {double ancho = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      borderSide: BorderSide(color: color, width: ancho),
    );
  }

  /// Barra fija inferior con el CTA y la ayuda de por qué está deshabilitado.
  Widget _barraInferior(bool tieneDescripcion) {
    final habilitado = !_loading && tieneDescripcion && _tipoId != null;

    // `resizeToAvoidBottomInset` sólo achica el body: el `bottomNavigationBar`
    // lo posiciona el Scaffold contra el borde inferior de la pantalla, o sea
    // DETRÁS del teclado (ver `_ScaffoldLayout.performLayout`). Se lo levanta a
    // mano para que el CTA quede siempre a la vista mientras se escribe.
    final alturaTeclado = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: alturaTeclado),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(top: BorderSide(color: context.colors.outline)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonHeight,
                  child: FilledButton(
                    onPressed: habilitado ? _guardar : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.habitsAccent,
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
                        : Text(
                            _esEdicion ? 'Guardar cambios' : 'Registrar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                // La ayuda aparece y desaparece sin empujar de golpe el CTA.
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: tieneDescripcion
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(
                            'Completá la descripción para continuar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: context.colors.textDisabled,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
