import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/exceptions/exceptions.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de inicio de sesión (US-02).
///
/// El email es el identificador único de acceso. En éxito NO navega: el redirect
/// del router se dispara automáticamente al cambiar [authStateProvider].
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? _emailError;
  String? _passwordError;
  String? _loginError;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    final emailErr = validateEmail(_emailController.text);
    final passErr = validatePassword(_passwordController.text);
    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
      _loginError = null;
    });
    return emailErr == null && passErr == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    await ref
        .read(authStateProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    final authState = ref.read(authStateProvider);
    if (authState.hasError && mounted) {
      setState(() {
        final error = authState.error;
        if (error is SinConexionException) {
          _loginError = 'Sin conexión. Verificá tu red e intentá de nuevo.';
        } else {
          // Mensaje genérico para CredencialesInvalidasException y cualquier
          // otro error: no revela si es el email o la contraseña.
          _loginError =
              'Credenciales incorrectas. Verificá e intentá de nuevo.';
        }
      });
    }
    // En éxito: el redirect del router maneja la navegación automáticamente.
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 56),

              // Logo + wordmark
              const _CareWellLogo(),
              const SizedBox(height: AppSpacing.xxxl),

              // Campo email
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
                textInputAction: TextInputAction.next,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(() => _emailError = null);
                  }
                  if (_loginError != null) {
                    setState(() => _loginError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Campo contraseña
              AppTextField(
                label: 'Contraseña',
                hint: 'Ingresá tu contraseña',
                controller: _passwordController,
                errorText: _passwordError,
                focusNode: _passwordFocus,
                obscureText: !_showPassword,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: _showPassword
                      ? 'Ocultar contraseña'
                      : 'Mostrar contraseña',
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                  if (_loginError != null) {
                    setState(() => _loginError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sm),

              // Link olvidé contraseña
              Align(
                alignment: Alignment.centerRight,
                child: SecondaryTextButton(
                  label: '¿Olvidaste tu contraseña?',
                  onPressed: isLoading
                      ? null
                      : () => context.pushNamed(AppRoutes.recoverPasswordName),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Error de login
              if (_loginError != null) ...[
                InlineErrorBanner(message: _loginError!),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Botón ingresar
              PrimaryButton(
                label: 'Ingresar',
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Divider con "o"
              _Divider(),
              const SizedBox(height: AppSpacing.xl),

              // Bloque registro
              _RegistroBlock(
                onTap: isLoading
                    ? null
                    : () => context.pushNamed(AppRoutes.registerName),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Link crear credenciales
              Center(
                child: SecondaryTextButton(
                  label: 'Mi cuenta fue creada por otro',
                  onPressed: isLoading
                      ? null
                      : () =>
                            context.pushNamed(AppRoutes.createCredentialsName),
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

// ─── Widgets locales ─────────────────────────────────────────────────────────

/// Logo + wordmark + tagline de CareWell.
class _CareWellLogo extends StatelessWidget {
  const _CareWellLogo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Logo real de CareWell
        Image.asset('assets/images/carewell-logo.png', width: 100, height: 100),
        const SizedBox(height: AppSpacing.md),
        // Wordmark bicolor
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Care',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'Well',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Cuidá en equipo',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Divider con label "o" centrado.
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'o',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.outline)),
      ],
    );
  }
}

/// Bloque de acceso a registro.
class _RegistroBlock extends StatelessWidget {
  const _RegistroBlock({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿No tenés cuenta?  ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Crear cuenta',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
