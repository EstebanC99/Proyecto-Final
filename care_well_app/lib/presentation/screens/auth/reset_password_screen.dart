import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/exceptions/exceptions.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Paso 2/2 de recuperación de contraseña (US-03): confirmar código OTP y
/// establecer la nueva contraseña.
///
/// Combina en una sola pantalla el código de 6 dígitos y la nueva
/// contraseña porque el backend expone un único endpoint
/// (`confirmar-reset-contrasena`) que recibe ambos datos juntos: separarlos
/// en dos pantallas agregaría un paso sin necesidad real.
///
/// En éxito, el backend cambia la contraseña y cierra las sesiones activas
/// en otros dispositivos. NO inicia sesión: se navega a la pantalla de
/// éxito y desde ahí al login.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  static const int _codigoLength = 6;
  static const int _cooldownSegundos = 60;

  final _codigoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _codigoFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String? _codigoError;
  String? _passwordError;
  String? _confirmError;
  String? _generalError;

  bool _showPassword = false;
  bool _showConfirm = false;
  bool _isSubmitting = false;
  bool _isResending = false;

  // Cooldown local optimista del botón "Reenviar" (mismo mecanismo que
  // VerifyEmailScreen). A diferencia de esa pantalla, acá arranca activo
  // desde `initState` (no en 0): el código recién se pidió en el paso
  // anterior, así que reenviar de inmediato no tiene sentido y además
  // puede chocar con el cooldown real del backend.
  Timer? _cooldownTimer;
  int _cooldownRestante = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _codigoController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _codigoFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // ── Cooldown ──────────────────────────────────────────────────────────────────

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownRestante = _cooldownSegundos);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldownRestante--;
        if (_cooldownRestante <= 0) timer.cancel();
      });
    });
  }

  bool get _enCooldown => _cooldownRestante > 0;

  // ── Validación local ──────────────────────────────────────────────────────────

  bool _validar() {
    final codigo = _codigoController.text.trim();
    String? codigoErr;
    if (codigo.isEmpty) {
      codigoErr = 'Ingresá el código que te enviamos.';
    } else if (codigo.length != _codigoLength) {
      codigoErr = 'El código tiene $_codigoLength dígitos.';
    }
    final passErr = validatePassword(_passwordController.text);
    final confirmErr = validatePasswordMatch(
      _confirmController.text,
      _passwordController.text,
    );
    setState(() {
      _codigoError = codigoErr;
      _passwordError = passErr;
      _confirmError = confirmErr;
      _generalError = null;
    });
    return codigoErr == null && passErr == null && confirmErr == null;
  }

  // ── Confirmar ─────────────────────────────────────────────────────────────────

  Future<void> _confirmar() async {
    if (!_validar()) return;

    setState(() => _isSubmitting = true);

    final confirmar = ref.read(confirmarResetContrasenaProvider);
    try {
      await confirmar(
        widget.email,
        _codigoController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      // Éxito: no se inicia sesión. Se reemplaza el stack para que el back
      // del sistema no vuelva a este formulario (el código ya se consumió).
      context.goNamed(AppRoutes.resetPasswordSuccessName);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        if (error is ValidacionException) {
          final mensaje = error.mensaje.toLowerCase();
          if (mensaje.contains('código')) {
            _codigoError = error.mensaje;
          } else if (mensaje.contains('contraseña')) {
            _passwordError = error.mensaje;
          } else {
            _generalError = error.mensaje;
          }
        } else if (error is SinConexionException) {
          _generalError = 'Sin conexión. Verificá tu red e intentá de nuevo.';
        } else {
          _generalError =
              'No pudimos restablecer tu contraseña. Intentá de nuevo.';
        }
      });
    }
  }

  // ── Reenviar ──────────────────────────────────────────────────────────────────

  Future<void> _reenviar() async {
    if (_enCooldown || _isResending) return;

    setState(() {
      _isResending = true;
      _generalError = null;
    });

    final solicitar = ref.read(solicitarRecuperacionContrasenaProvider);
    try {
      await solicitar(widget.email);
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _codigoController.clear();
      });
      _startCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Te enviamos un nuevo código a tu email.'),
          backgroundColor: context.colors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        if (error is ValidacionException) {
          // Cooldown/tope del backend: mostramos su mensaje.
          _generalError = error.mensaje;
        } else if (error is SinConexionException) {
          _generalError = 'Sin conexión. Verificá tu red e intentá de nuevo.';
        } else {
          _generalError = 'No pudimos reenviar el código. Intentá de nuevo.';
        }
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = _isSubmitting || _isResending;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: isBusy ? null : () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
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
              StepProgressBar(currentStep: 2, totalSteps: 2),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Ingresá el código y tu nueva contraseña',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Te enviamos un código de 6 dígitos a ',
                    ),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Código OTP
              AppTextField(
                label: 'Código de verificación',
                hint: '000000',
                controller: _codigoController,
                errorText: _codigoError,
                helperText: _codigoError == null
                    ? 'Vence a los 10 minutos de haberlo pedido.'
                    : null,
                enabled: !isBusy,
                focusNode: _codigoFocus,
                keyboardType: TextInputType.number,
                autocorrect: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_codigoLength),
                ],
                prefixIcon: const Icon(Icons.password_outlined, size: 20),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
                onChanged: (_) {
                  if (_codigoError != null) {
                    setState(() => _codigoError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              Text(
                'Nueva contraseña',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Nueva contraseña
              AppTextField(
                label: 'Nueva contraseña',
                hint: 'Ingresá tu nueva contraseña',
                controller: _passwordController,
                errorText: _passwordError,
                enabled: !isBusy,
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
                    color: context.colors.textSecondary,
                  ),
                  tooltip: _showPassword
                      ? 'Ocultar contraseña'
                      : 'Mostrar contraseña',
                ),
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_confirmFocus),
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                  setState(() {}); // refresca PasswordStrengthMeter
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              PasswordStrengthMeter(password: _passwordController.text),
              const SizedBox(height: AppSpacing.lg),

              // Confirmar nueva contraseña
              AppTextField(
                label: 'Confirmar nueva contraseña',
                hint: 'Repetí tu nueva contraseña',
                controller: _confirmController,
                errorText: _confirmError,
                enabled: !isBusy,
                focusNode: _confirmFocus,
                obscureText: !_showConfirm,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _showConfirm = !_showConfirm),
                  icon: Icon(
                    _showConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: context.colors.textSecondary,
                  ),
                  tooltip: _showConfirm
                      ? 'Ocultar contraseña'
                      : 'Mostrar contraseña',
                ),
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _confirmar(),
                onChanged: (_) {
                  if (_confirmError != null) {
                    setState(() => _confirmError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Error general
              if (_generalError != null) ...[
                InlineErrorBanner(message: _generalError!),
                const SizedBox(height: AppSpacing.lg),
              ],

              PrimaryButton(
                label: 'Restablecer contraseña',
                isLoading: _isSubmitting,
                onPressed: isBusy ? null : _confirmar,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Reenviar código
              Center(
                child: _enCooldown
                    ? Text(
                        'Podés reenviar el código en ${_cooldownRestante}s',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      )
                    : SecondaryTextButton(
                        label: _isResending
                            ? 'Enviando…'
                            : '¿No lo recibiste? Reenviar código',
                        onPressed: _isSubmitting || _isResending
                            ? null
                            : _reenviar,
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
