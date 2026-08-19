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
  /// Id del tipo seleccionado. `null` hasta que carga el catálogo.
  int? _tipoId;
  final _descripcionCtrl = TextEditingController();
  bool _loading = false;
  bool _precargado = false;

  /// La precarga ya terminó, con o sin éxito. Habilita el fallback al primer
  /// tipo del catálogo: sin esto, un hábito que no se encuentra dejaría el
  /// formulario sin tipo seleccionado y con el botón de guardar bloqueado.
  bool _precargaIntentada = false;

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
    } finally {
      if (mounted) setState(() => _precargaIntentada = true);
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
            animado(
              FormTextField(
                controller: _descripcionCtrl,
                label: 'Descripción',
                hintText: _placeholder,
                accent: context.colors.habitsAccent,
                enabled: !_loading,
              ),
              50,
            ),
          ],
        ),
      ),
      // Sólo la barra depende del texto: sin esto, cada tecla redibujaría la
      // grilla de tipos entera.
      bottomNavigationBar: animado(
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _descripcionCtrl,
          builder: (context, valor, _) {
            final tieneDescripcion = valor.text.trim().isNotEmpty;
            return FormBottomBar(
              label: _esEdicion ? 'Guardar cambios' : 'Registrar',
              accent: context.colors.habitsAccent,
              loading: _loading,
              onPressed: (tieneDescripcion && _tipoId != null)
                  ? _guardar
                  : null,
              hint: tieneDescripcion
                  ? null
                  : 'Completá la descripción para continuar',
            );
          },
        ),
        100,
      ),
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
            //
            // En edición se espera a que termine la precarga: si no, el primer
            // frame pinta el tile 1 elegido y al resolverse el hábito la
            // selección salta a otro tile a la vista del usuario.
            if (_tipoId == null && (!_esEdicion || _precargaIntentada)) {
              _tipoId = ordenados.first.id;
            }

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
}
