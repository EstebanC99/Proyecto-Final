import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/exceptions/exceptions.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de verificación de email por código OTP (alta de cuenta).
///
/// Se accede tras el registro exitoso o desde el login cuando la cuenta está
/// pendiente de validación (403). Recibe el email por `extra` de go_router.
///
/// El código es de 6 dígitos y expira en 10 minutos (regla del backend). Al
/// verificar OK la cuenta queda activa pero NO se inicia sesión: se navega a la
/// pantalla de éxito y desde ahí al login.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const int _codigoLength = 6;
  static const int _cooldownSegundos = 60;

  final _codigoController = TextEditingController();
  final _codigoFocus = FocusNode();

  String? _codigoError;
  String? _generalError;
  bool _isVerifying = false;
  bool _isResending = false;

  // Cooldown local optimista del botón "Reenviar". Arranca en 0 (habilitado).
  Timer? _cooldownTimer;
  int _cooldownRestante = 0;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _codigoController.dispose();
    _codigoFocus.dispose();
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

  // ── Verificar ─────────────────────────────────────────────────────────────────

  bool _validarCodigo() {
    final codigo = _codigoController.text.trim();
    String? error;
    if (codigo.isEmpty) {
      error = 'Ingresá el código que te enviamos.';
    } else if (codigo.length != _codigoLength) {
      error = 'El código tiene $_codigoLength dígitos.';
    }
    setState(() {
      _codigoError = error;
      _generalError = null;
    });
    return error == null;
  }

  Future<void> _verificar() async {
    if (!_validarCodigo()) return;

    setState(() => _isVerifying = true);

    final verificar = ref.read(verificarEmailProvider);
    try {
      await verificar(widget.email, _codigoController.text.trim());
      if (!mounted) return;
      // Éxito: la cuenta queda activa. Se navega a la pantalla de éxito
      // post-verificación; desde ahí el usuario va al login.
      context.goNamed(AppRoutes.accountCreatedName);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        if (error is ValidacionException) {
          // Código inválido/expirado/agotado: mostramos el mensaje del backend.
          _codigoError = error.mensaje;
        } else if (error is SinConexionException) {
          _generalError = 'Sin conexión. Verificá tu red e intentá de nuevo.';
        } else {
          _generalError = 'No pudimos verificar el código. Intentá de nuevo.';
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

    final reenviar = ref.read(reenviarCodigoVerificacionProvider);
    try {
      await reenviar(widget.email);
      if (!mounted) return;
      setState(() => _isResending = false);
      _startCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Te enviamos un nuevo código a tu email.'),
          backgroundColor: AppColors.success,
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.goNamed(AppRoutes.loginName),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Icon(
                Icons.mark_email_read_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Verificá tu email',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Ingresá el código de 6 dígitos que enviamos a ',
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

              // Campo de código OTP
              AppTextField(
                label: 'Código de verificación',
                hint: '000000',
                controller: _codigoController,
                errorText: _codigoError,
                focusNode: _codigoFocus,
                keyboardType: TextInputType.number,
                autocorrect: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_codigoLength),
                ],
                prefixIcon: const Icon(Icons.password_outlined, size: 20),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _verificar(),
                onChanged: (_) {
                  if (_codigoError != null) {
                    setState(() => _codigoError = null);
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
                label: 'Verificar',
                isLoading: _isVerifying,
                onPressed: _verificar,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Reenviar código
              Center(
                child: _enCooldown
                    ? Text(
                        'Podés reenviar el código en ${_cooldownRestante}s',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    : SecondaryTextButton(
                        label: _isResending
                            ? 'Enviando…'
                            : '¿No lo recibiste? Reenviar código',
                        onPressed: _isResending ? null : _reenviar,
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
