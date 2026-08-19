import 'package:flutter/material.dart';

import 'confirm_dialog.dart';

/// Pide confirmación antes de abandonar un formulario con cambios sin guardar.
///
/// Envuelve el `Scaffold` de la pantalla. Intercepta el gesto de "atrás" del
/// sistema y la flecha del AppBar —los dos pasan por `Navigator.maybePop`— y,
/// si [hayCambios] devuelve `true`, muestra un diálogo antes de salir.
///
/// El `Navigator.pop()` que hacen las pantallas después de guardar **no** pasa
/// por acá: `pop` sale sin consultar al `PopScope`, a diferencia de `maybePop`.
///
/// ## Por qué [hayCambios] es un callback y no un `bool`
/// Con un `bool` la pantalla tendría que reconstruirse en cada tecla para
/// mantenerlo actualizado, que es justamente lo que se sacó de los formularios
/// al acotar el rebuild al botón de guardar. Como callback se evalúa una sola
/// vez, cuando el usuario intenta salir.
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    super.key,
    required this.hayCambios,
    required this.child,
    this.titulo = 'Tenés cambios sin guardar',
    this.cuerpo = '¿Salir de todas formas?',
    this.confirmLabel = 'Salir',
  });

  /// Se consulta al intentar salir. `true` = hay algo que perder.
  final ValueGetter<bool> hayCambios;

  final Widget child;

  final String titulo;
  final String cuerpo;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        if (!hayCambios()) {
          if (context.mounted) Navigator.of(context).pop();
          return;
        }

        final confirmo = await ConfirmDialog.show(
          context,
          title: titulo,
          body: cuerpo,
          confirmLabel: confirmLabel,
          onConfirm: () async {},
          icon: Icons.warning_amber_rounded,
        );
        if (confirmo && context.mounted) Navigator.of(context).pop();
      },
      child: child,
    );
  }
}
