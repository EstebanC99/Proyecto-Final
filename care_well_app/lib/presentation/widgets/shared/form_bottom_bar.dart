import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Barra fija al pie de un formulario, con la acción principal.
///
/// Saca el CTA del scroll para que esté siempre a mano, y muestra debajo una
/// ayuda opcional que explica por qué la acción está deshabilitada.
///
/// Pensada para usarse como `Scaffold.bottomNavigationBar`.
class FormBottomBar extends StatelessWidget {
  const FormBottomBar({
    super.key,
    required this.label,
    required this.onPressed,
    required this.accent,
    this.loading = false,
    this.hint,
  });

  /// Texto del botón principal.
  final String label;

  /// Acción principal. En `null` el botón queda deshabilitado.
  final VoidCallback? onPressed;

  /// Color de fondo del botón (el acento del módulo).
  final Color accent;

  /// Muestra un spinner en lugar del texto mientras se guarda.
  final bool loading;

  /// Ayuda debajo del botón. En `null` no ocupa lugar.
  ///
  /// Se usa para explicar qué falta completar; aparece y desaparece con una
  /// transición de alto para que el botón no salte.
  final String? hint;

  @override
  Widget build(BuildContext context) {
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
                    onPressed: loading ? null : onPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                    ),
                    child: loading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: context.colors.onPrimary,
                            ),
                          )
                        : Text(
                            label,
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
                  child: hint == null
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(
                            hint!,
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
