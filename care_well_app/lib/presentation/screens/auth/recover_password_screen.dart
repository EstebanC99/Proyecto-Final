import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de recuperación de contraseña (US-03).
///
/// Solicita el email y simula el envío del link. En éxito muestra
/// confirmación inline sin cambiar de ruta.
///
/// Las pantallas de "nueva contraseña" y "cambio exitoso" son stubs:
/// requieren deep-link con token (futura iteración).
// TODO(deep-link): implementar pantallas de reset cuando se tenga token de reset.
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
  bool _isLoading = false;
  bool _enviado = false;

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
      _emailError = null;
    });

    final solicitar = ref.read(solicitarRecuperacionContrasenaProvider);
    try {
      await solicitar(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _enviado = true;
      });
    } catch (_) {
      if (!mounted) return;
      // Mensaje genérico: no revela si el email existe en el sistema.
      setState(() {
        _isLoading = false;
        _enviado = true; // En demo siempre mostramos "enviado".
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
          child: _enviado ? _buildConfirmacion(theme) : _buildFormulario(theme),
        ),
      ),
    );
  }

  // ── Vista de formulario ────────────────────────────────────────────────────

  Widget _buildFormulario(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Recuperar contraseña',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Ingresá el email asociado a tu cuenta y te enviaremos un link para restablecer tu contraseña.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        AppTextField(
          label: 'Email',
          hint: 'tucorreo@ejemplo.com',
          controller: _emailController,
          errorText: _emailError,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          prefixIcon: const Icon(Icons.mail_outline, size: 20),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _enviar(),
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        ),
        const SizedBox(height: AppSpacing.xl),

        PrimaryButton(
          label: 'Enviar link de restablecimiento',
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
    );
  }

  // ── Vista de confirmación ──────────────────────────────────────────────────

  Widget _buildConfirmacion(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 40,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Revisá tu email',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: 'Enviamos un link a '),
              TextSpan(
                text: _emailController.text.trim(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '. Revisá también la carpeta de spam.'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: 'Volver al inicio de sesión',
          onPressed: () => context.pop(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: SecondaryTextButton(
            label: '¿No recibiste el email? Reenviar',
            onPressed: () {
              setState(() => _isLoading = true);
              final solicitar = ref.read(
                solicitarRecuperacionContrasenaProvider,
              );
              solicitar(_emailController.text.trim()).whenComplete(() {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link reenviado.')),
                  );
                }
              });
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
