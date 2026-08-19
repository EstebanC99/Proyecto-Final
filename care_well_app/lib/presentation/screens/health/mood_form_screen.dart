import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de registro del estado de ánimo (US-31).
class MoodFormScreen extends ConsumerStatefulWidget {
  const MoodFormScreen({super.key});

  @override
  ConsumerState<MoodFormScreen> createState() => _MoodFormScreenState();
}

class _MoodFormScreenState extends ConsumerState<MoodFormScreen> {
  /// Tope de caracteres de la observación, igual al del campo compartido.
  static const _maxObservacion = 500;

  /// Frases frecuentes que se pueden agregar a la observación con un toque.
  static const _sugerencias = [
    'Durmió bien',
    'Con energía',
    'Decaído',
    'Ansioso',
  ];

  /// Nivel elegido. Arranca en `null`: la pantalla no propone ningún estado,
  /// para no inducir un registro que el usuario no eligió.
  int? _level;

  final _observacionesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _observacionesCtrl.dispose();
    super.dispose();
  }

  /// Agrega [sugerencia] al final de la observación, sin pisar lo escrito.
  void _agregarSugerencia(String sugerencia) {
    final actual = _observacionesCtrl.text.trimRight();
    final texto = actual.isEmpty
        ? sugerencia
        : actual.endsWith('.')
        ? '$actual $sugerencia'
        : '$actual. $sugerencia';

    _observacionesCtrl.value = TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  Future<void> _registrar() async {
    final level = _level;
    if (level == null) return;

    setState(() => _loading = true);
    try {
      final observaciones = _observacionesCtrl.text.trim();
      await ref.read(registrarAnimoProvider)(
        estadoAnimoId: level,
        observaciones: observaciones.isEmpty ? null : observaciones,
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
      appBar: const ContextAppBar(
        eyebrow: 'Estado de ánimo',
        // El registro es de la persona de contexto: cambiarla a mitad de la
        // carga movería el destino de lo ya elegido.
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
            animado(_encabezado(nombrePersona), 0),
            const SizedBox(height: AppSpacing.lg),
            animado(
              MoodScaleSelector(
                selectedLevel: _level,
                onChanged: (nivel) => setState(() => _level = nivel),
                enabled: !_loading,
              ),
              50,
            ),
            animado(
              FormTextField(
                controller: _observacionesCtrl,
                label: 'Observación',
                hintText: 'Ej. Estuvo tranquila, durmió bien',
                accent: context.colors.moodAccent,
                enabled: !_loading,
                required: false,
                maxLength: _maxObservacion,
              ),
              100,
            ),
            animado(_sugerenciasChips(), 150),
            animado(_ultimoRegistro(), 150),
          ],
        ),
      ),
      // El botón depende del nivel elegido, no del texto: acá no hace falta
      // escuchar al controller.
      bottomNavigationBar: animado(
        FormBottomBar(
          label: 'Registrar estado',
          accent: context.colors.moodAccent,
          loading: _loading,
          onPressed: _level == null ? null : _registrar,
          hint: _level == null ? 'Elegí cómo se siente para continuar' : null,
        ),
        150,
      ),
    );
  }

  Widget _encabezado(String nombrePersona) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo se siente $nombrePersona hoy?',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tocá la carita que mejor lo describa.',
          style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
        ),
      ],
    );
  }

  /// Frases de uso frecuente que se concatenan a la observación.
  ///
  /// Sólo esta fila escucha al controller: el resto de la pantalla no se
  /// redibuja al tipear.
  Widget _sugerenciasChips() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _observacionesCtrl,
      builder: (context, valor, _) {
        final texto = valor.text;

        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final sugerencia in _sugerencias)
                _SugerenciaChip(
                  texto: sugerencia,
                  // Se deshabilita en vez de no hacer nada al tocarlo: un chip
                  // que responde con silencio parece roto.
                  onTap:
                      _loading ||
                          texto.contains(sugerencia) ||
                          texto.characters.length + sugerencia.length + 2 >
                              _maxObservacion
                      ? null
                      : () => _agregarSugerencia(sugerencia),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Recuerda el último registro del día, si lo hay.
  ///
  /// Es decorativo: mientras carga, o si todavía no se registró nada hoy, no
  /// ocupa lugar. Registrar de nuevo sobrescribe, y este pie es el aviso.
  Widget _ultimoRegistro() {
    final animo = ref
        .watch(animoHoyProvider)
        .maybeWhen(data: (a) => a, orElse: () => null);
    if (animo == null) return const SizedBox.shrink();

    final hora = TimeOfDay.fromDateTime(animo.fecha).format(context);
    final descripcion = moodLabelForLevel(animo.estado.id);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          descripcion == null
              ? 'Último registro: hoy $hora'
              : 'Último registro: hoy $hora · $descripcion',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
        ),
      ),
    );
  }
}

/// Chip de sugerencia. Deshabilitado si ya está en la observación.
class _SugerenciaChip extends StatelessWidget {
  const _SugerenciaChip({required this.texto, required this.onTap});

  final String texto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final habilitado = onTap != null;
    final colors = context.colors;

    return Semantics(
      button: true,
      enabled: habilitado,
      label: texto,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: habilitado ? colors.surface : colors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(color: colors.outline),
            ),
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: habilitado ? colors.textSecondary : colors.textDisabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
