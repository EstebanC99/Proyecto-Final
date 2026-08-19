import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Muestra el diálogo "Acerca de CareWell".
///
/// Se arma con [AboutDialog] + [showDialog] en lugar de `showAboutDialog`
/// **a propósito**: `showAboutDialog` es literalmente un wrapper de
/// `showDialog<void>` sobre el mismo [AboutDialog] (mismos botones "Ver
/// licencias" y "Cerrar" de fábrica), pero devuelve `void`. Con él, el `await`
/// de quien lo llama completaría al ABRIR el diálogo y no al cerrarse. Usando
/// el widget directo el resultado es idéntico en pantalla y además se obtiene
/// un `Future<void>` con semántica real y el `barrierColor` propio de la app.
///
/// `useRootNavigator` queda implícito (`true` por defecto en [showDialog], igual
/// que en `showAboutDialog`) para preservar el comportamiento bajo el
/// `ShellRoute` de go_router.
///
/// Recibe la versión ya resuelta (no un `WidgetRef`): así el diálogo es
/// presentación pura, testeable sin `ProviderScope` ni mocks de plugins.
Future<void> mostrarAcercaDeCareWell(
  BuildContext context, {
  required String version,
}) {
  final theme = Theme.of(context);
  final estiloCuerpo = theme.textTheme.bodyMedium?.copyWith(
    color: context.colors.textSecondary,
    height: 1.5,
  );

  return showDialog<void>(
    context: context,
    barrierColor: context.colors.scrim,
    builder: (_) => AboutDialog(
      applicationName: 'CareWell',
      applicationVersion: 'Versión $version',
      applicationIcon: Image.asset(
        'assets/images/carewell-logo.png',
        width: 48,
        height: 48,
      ),
      applicationLegalese: '© Bubisoft',
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          'CareWell centraliza la información de la persona bajo cuidado y '
          'coordina al equipo de responsables y cuidadores que participan en '
          'su cuidado.',
          style: estiloCuerpo,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Contacto: terminos_condiciones@bubisoft.com',
          style: estiloCuerpo,
        ),
      ],
    ),
  );
}
