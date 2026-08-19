import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_palette.dart';
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
    // El botón ya está deshabilitado con el campo vacío; esto sólo cierra el
    // paso por si alguna vez se lo invoca por otro camino.
    if (contenido.isEmpty) return;

    setState(() => _loading = true);
    try {
      await ref.read(agregarNotaEventoProvider)(
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
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _shouldPop();
        if (ok && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: const ContextAppBar(
          eyebrow: 'Nueva nota',
          // La nota pertenece a un evento de una persona concreta: dejar
          // cambiar de persona acá no tendría sentido.
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
              animado(_contextoDelEvento(), 0),
              animado(
                FormTextField(
                  controller: _contenidoCtrl,
                  label: 'Nota',
                  hintText: 'Escribí tu observación sobre este evento...',
                  accent: context.colors.healthAccent,
                  enabled: !_loading,
                  minLines: 5,
                  maxLines: 12,
                  labelPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
                ),
                50,
              ),
            ],
          ),
        ),
        bottomNavigationBar: animado(
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _contenidoCtrl,
            builder: (context, valor, _) {
              final tieneContenido = valor.text.trim().isNotEmpty;
              return FormBottomBar(
                label: 'Guardar nota',
                accent: context.colors.healthAccent,
                loading: _loading,
                onPressed: tieneContenido ? _guardar : null,
                hint: tieneContenido ? null : 'Escribí la nota para continuar',
              );
            },
          ),
          100,
        ),
      ),
    );
  }

  /// Recuerda a qué evento se le está agregando la nota.
  ///
  /// Es deliberadamente decorativo: si el evento todavía no resolvió, o no está
  /// en la semana cargada, no se dibuja nada. Un formulario que hoy nunca falla
  /// al renderizar no debería estrenar estados de carga ni de error por una
  /// línea de contexto.
  Widget _contextoDelEvento() {
    final evento = ref
        .watch(eventoSaludByIdProvider(widget.eventoId))
        .maybeWhen(data: (e) => e, orElse: () => null);
    if (evento == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            TipoEventoTheme.iconFor(evento.tipo.id),
            size: 18,
            color: TipoEventoTheme.accentFor(context, evento.tipo.id),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              evento.descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
