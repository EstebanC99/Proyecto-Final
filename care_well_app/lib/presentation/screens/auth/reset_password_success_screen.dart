import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../widgets/widgets.dart';

/// Paso 3/3 de recuperación de contraseña (US-03): confirmación de éxito.
///
/// Pantalla terminal: la contraseña ya se actualizó y las sesiones activas
/// en otros dispositivos fueron cerradas por el backend. No se inicia sesión
/// automáticamente. El back del sistema lleva al login en vez de volver al
/// formulario (el código ya fue consumido, no tiene sentido volver).
class ResetPasswordSuccessScreen extends StatelessWidget {
  const ResetPasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.goNamed(AppRoutes.loginName);
      },
      child: SuccessView(
        title: '¡Contraseña actualizada!',
        subtitle:
            'Ya podés iniciar sesión con tu nueva contraseña. Por seguridad, '
            'cerramos tu sesión en otros dispositivos.',
        primaryButtonLabel: 'Ir al inicio de sesión',
        onPrimaryTap: () => context.goNamed(AppRoutes.loginName),
      ),
    );
  }
}
