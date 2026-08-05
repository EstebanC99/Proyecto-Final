import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/exceptions/exceptions.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Paso 1/2 de recuperación de contraseña (US-03): solicitar el código.
///
/// El backend envía un código OTP de 6 dígitos por email si la cuenta existe
/// y está activa. Por seguridad, si el email no existe la respuesta es
/// igualmente exitosa (no se revela si una cuenta existe o no).
///
/// Caso especial: si la cuenta existe pero no está activa (ej. pendiente de
/// verificación de email), el backend sí lo informa explícitamente. Ese caso
/// se muestra con un banner de advertencia (no de error) que orienta al
/// usuario a verificar su email primero, con una acción directa para hacerlo.
class RecoverPasswordScreen extends ConsumerStatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  ConsumerState<RecoverPasswordScreen> createState() =>
      _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends ConsumerState<RecoverPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  String? _emailError;
  String? _generalError;
  BannerTone _generalErrorTone = BannerTone.error;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    final err = validateEmail(_emailController.text);
    setState(() => _emailError = err);
    return err == null;
  }

  Future<void> _enviar() async {
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
      _generalError = null;
    });

    final email = _emailController.text.trim();
    final solicitar = ref.read(solicitarRecuperacionContrasenaProvider);
    try {
      await solicitar(email);
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Éxito (o email inexistente, que el backend responde igual por
      // seguridad): se avanza al paso 2 a ingresar el código.
      context.pushNamed(AppRoutes.resetPasswordName, extra: email);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (error is ValidacionException &&
            error.mensaje.toLowerCase().contains('habilitada')) {
          // Cuenta existente pero no activa (ej. email sin verificar).
          // Decisión de producto: se informa explícitamente en vez de
          // ocultarlo, con tono de advertencia (no de error) y una acción
          // que orienta a resolverlo.
          _generalErrorTone = BannerTone.warning;
          _generalError =
              'Todavía no pudimos habilitar el restablecimiento para esta '
              'cuenta. Si te registraste hace poco, es posible que falte '
              'verificar tu email.';
        } else if (error is ValidacionException) {
          // Otros casos de validación del backend (ej. límite de envíos por
          // hora superado): se muestra el mensaje tal cual, ya es claro.
          _generalErrorTone = BannerTone.error;
          _generalError = error.mensaje;
        } else if (error is SinConexionException) {
          _generalErrorTone = BannerTone.error;
          _generalError = 'Sin conexión. Verificá tu red e intentá de nuevo.';
        } else {
          _generalErrorTone = BannerTone.error;
          _generalError = 'No pudimos procesar tu pedido. Intentá de nuevo.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver al inicio de sesión',
        ),
        title: const Text('Recuperar contraseña'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              StepProgressBar(currentStep: 1, totalSteps: 2),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Recuperar contraseña',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Ingresá el email asociado a tu cuenta. Si está activa, te '
                'vamos a enviar un código de 6 dígitos para restablecer tu '
                'contraseña.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppTextField(
                label: 'Email',
                hint: 'tucorreo@ejemplo.com',
                controller: _emailController,
                errorText: _emailError,
                enabled: !_isLoading,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                prefixIcon: const Icon(Icons.mail_outline, size: 20),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _enviar(),
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                  if (_generalError != null) {
                    setState(() => _generalError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              if (_generalError != null) ...[
                InlineErrorBanner(
                  message: _generalError!,
                  tone: _generalErrorTone,
                  icon: _generalErrorTone == BannerTone.warning
                      ? Icons.mark_email_unread_outlined
                      : null,
                  actionLabel: _generalErrorTone == BannerTone.warning
                      ? 'Verificar mi email'
                      : null,
                  onAction: _generalErrorTone == BannerTone.warning
                      ? () => context.pushNamed(
                          AppRoutes.verifyEmailName,
                          extra: _emailController.text.trim(),
                        )
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              PrimaryButton(
                label: 'Enviar código',
                isLoading: _isLoading,
                onPressed: _enviar,
              ),
              const SizedBox(height: AppSpacing.lg),

              Center(
                child: SecondaryTextButton(
                  label: 'Volver al inicio de sesión',
                  onPressed: _isLoading ? null : () => context.pop(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
