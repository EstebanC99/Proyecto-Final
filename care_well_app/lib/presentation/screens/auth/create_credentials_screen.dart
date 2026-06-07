import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de creación de credenciales para personas preexistentes (US-04).
///
/// Caso de uso: una persona fue dada de alta por un responsable/cuidador y
/// ahora quiere crear sus propias credenciales de acceso.
///
/// Email de prueba (demo): roberto.sanchez@example.com
class CreateCredentialsScreen extends ConsumerStatefulWidget {
  const CreateCredentialsScreen({super.key});

  @override
  ConsumerState<CreateCredentialsScreen> createState() =>
      _CreateCredentialsScreenState();
}

class _CreateCredentialsScreenState
    extends ConsumerState<CreateCredentialsScreen> {
  final _emailController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _emailFocus = FocusNode();
  final _usuarioFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String? _emailError;
  String? _usuarioError;
  String? _passwordError;
  String? _confirmError;
  String? _generalError;

  bool _showPassword = false;
  bool _tcAcepted = false;
  String? _tcError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usuarioController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
    _usuarioFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    final emailErr = validateEmail(_emailController.text);
    final usuarioErr = validateNombreUsuario(_usuarioController.text);
    final passErr = validatePassword(_passwordController.text);
    final confirmErr = validatePasswordMatch(
      _confirmController.text,
      _passwordController.text,
    );
    final tcErr = _tcAcepted
        ? null
        : 'Tenés que aceptar los Términos y Condiciones.';
    setState(() {
      _emailError = emailErr;
      _usuarioError = usuarioErr;
      _passwordError = passErr;
      _confirmError = confirmErr;
      _tcError = tcErr;
      _generalError = null;
    });
    return emailErr == null &&
        usuarioErr == null &&
        passErr == null &&
        confirmErr == null &&
        tcErr == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    final result = await ref
        .read(authStateProvider.notifier)
        .crearCredenciales(
          email: _emailController.text.trim(),
          nombreUsuario: _usuarioController.text.trim(),
          contrasena: _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      data: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Credenciales creadas! Ya podés iniciar sesión.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.goNamed(AppRoutes.loginName);
      },
      error: (error, _) {
        final msg = error.toString();
        // Acá sí se puede ser específico: no es un flujo de seguridad.
        if (msg.toLowerCase().contains('no encontrada')) {
          setState(
            () => _emailError = 'No encontramos ningún perfil con ese email.',
          );
        } else if (msg.toLowerCase().contains('ya tiene credenciales')) {
          setState(
            () => _emailError =
                'Esta persona ya tiene credenciales. Podés ir al inicio de sesión.',
          );
        } else if (msg.toLowerCase().contains('nombre de usuario')) {
          setState(
            () => _usuarioError = 'El nombre de usuario ya está en uso.',
          );
        } else {
          setState(
            () => _generalError =
                'Error al crear las credenciales. Intentá de nuevo.',
          );
        }
      },
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
        ),
        title: const Text('Crear mis credenciales'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Texto explicativo
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Tu cuenta fue creada por un familiar o cuidador. '
                        'Completá tus datos para poder acceder.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Email (identifica la persona preexistente)
              AppTextField(
                label: 'Email',
                hint: 'Email con el que fuiste registrado',
                controller: _emailController,
                errorText: _emailError,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                prefixIcon: const Icon(Icons.mail_outline, size: 20),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_usuarioFocus),
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Nombre de usuario
              AppTextField(
                label: 'Nombre de usuario',
                hint: 'Ej. maria.garcia',
                controller: _usuarioController,
                errorText: _usuarioError,
                focusNode: _usuarioFocus,
                autocorrect: false,
                prefixIcon: const Icon(Icons.alternate_email, size: 20),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
                onChanged: (_) {
                  if (_usuarioError != null) {
                    setState(() => _usuarioError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Contraseña
              AppTextField(
                label: 'Nueva contraseña',
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
                textInputAction: TextInputAction.next,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_confirmFocus),
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                  setState(() {}); // actualiza PasswordStrengthMeter
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              PasswordStrengthMeter(password: _passwordController.text),
              const SizedBox(height: AppSpacing.lg),

              // Confirmar contraseña
              AppTextField(
                label: 'Confirmar contraseña',
                hint: 'Repetí tu contraseña',
                controller: _confirmController,
                errorText: _confirmError,
                focusNode: _confirmFocus,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_confirmError != null) {
                    setState(() => _confirmError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Checkbox T&C
              _TcRow(
                accepted: _tcAcepted,
                error: _tcError,
                onChanged: (value) {
                  setState(() {
                    _tcAcepted = value ?? false;
                    if (_tcAcepted) _tcError = null;
                  });
                },
                onTermsTap: () async {
                  final accepted = await TermsBottomSheet.show(context);
                  if (accepted == true) {
                    setState(() {
                      _tcAcepted = true;
                      _tcError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Error general
              if (_generalError != null) ...[
                InlineErrorBanner(message: _generalError!),
                const SizedBox(height: AppSpacing.lg),
              ],

              PrimaryButton(
                label: 'Crear credenciales',
                isLoading: _isLoading,
                onPressed: _tcAcepted ? _submit : null,
              ),
              const SizedBox(height: AppSpacing.md),

              Center(
                child: SecondaryTextButton(
                  label: '¿Tenés cuenta? Iniciar sesión',
                  onPressed: () => context.pop(),
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

// ─── Widget de fila T&C ───────────────────────────────────────────────────────

class _TcRow extends StatelessWidget {
  const _TcRow({
    required this.accepted,
    required this.error,
    required this.onChanged,
    required this.onTermsTap,
  });

  final bool accepted;
  final String? error;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTermsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onChanged(!accepted),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(value: accepted, onChanged: onChanged),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      const TextSpan(text: 'Acepto los '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: onTermsTap,
                          child: Text(
                            'Términos y Condiciones',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: Text(
              error!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
