import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/exceptions/exceptions.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de registro en 3 pasos (US-01).
///
/// Paso 1: datos personales (nombre, apellido, documento, fecha de nacimiento,
///   email, teléfono) y foto de perfil opcional.
/// Paso 2: verificación de identidad — foto del documento (obligatoria).
/// Paso 3: credenciales (contraseña, confirmación, T&C).
///
/// En éxito: continúa a la verificación de email.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // ── Controladores Paso 1 ────────────────────────────────────────────────────
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _documentoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();

  // ── Focus nodes Paso 1 ──────────────────────────────────────────────────────
  final _nombreFocus = FocusNode();
  final _apellidoFocus = FocusNode();
  final _documentoFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _telefonoFocus = FocusNode();

  // ── Fecha de nacimiento (Paso 1) ─────────────────────────────────────────────
  DateTime? _fechaNacimiento;
  String? _fechaNacimientoError;

  // ── Errores Paso 1 ──────────────────────────────────────────────────────────
  String? _nombreError;
  String? _apellidoError;
  String? _documentoError;
  String? _emailError;
  String? _telefonoError;

  // ── Controladores Paso 2 ────────────────────────────────────────────────────
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  // ── Errores Paso 2 ──────────────────────────────────────────────────────────
  String? _passwordError;
  String? _confirmError;
  String? _tcError;
  String? _generalError;
  BannerTone _generalErrorTone = BannerTone.error;

  bool _showPassword = false;
  bool _showConfirm = false;
  bool _tcAcepted = false;

  // ── Fotos ───────────────────────────────────────────────────────────────────
  /// Foto de perfil en base64 (opcional). Fallback a iniciales si es null.
  String? _imagenPerfil;

  /// Foto del documento en base64 (obligatoria). PII sensible: solo vive en
  /// memoria durante el wizard y se limpia tras el submit.
  String? _imagenDocumento;
  String? _imagenDocumentoError;

  // ── Estado de paso ──────────────────────────────────────────────────────────
  // Paso 1: datos personales · Paso 2: identidad (documento) · Paso 3: credenciales.
  int _currentStep = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _documentoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _nombreFocus.dispose();
    _apellidoFocus.dispose();
    _documentoFocus.dispose();
    _emailFocus.dispose();
    _telefonoFocus.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  bool get _hasDatosPaso1 =>
      _nombreController.text.isNotEmpty ||
      _apellidoController.text.isNotEmpty ||
      _documentoController.text.isNotEmpty ||
      _emailController.text.isNotEmpty ||
      _telefonoController.text.isNotEmpty ||
      _fechaNacimiento != null ||
      _imagenPerfil != null ||
      _imagenDocumento != null;

  // ── Validaciones ─────────────────────────────────────────────────────────────

  bool _validatePaso1() {
    final nombreErr = validateNombre(_nombreController.text);
    final apellidoErr = validateApellido(_apellidoController.text);
    final documentoErr = validateDocumento(_documentoController.text);
    final fechaErr = validateFechaNacimiento(_fechaNacimiento);
    final emailErr = validateEmail(_emailController.text);
    // Teléfono: requerido en UI para registro.
    String? telefonoErr = validateTelefono(_telefonoController.text);
    if (telefonoErr == null && _telefonoController.text.trim().isEmpty) {
      telefonoErr = 'Ingresá tu teléfono.';
    }
    setState(() {
      _nombreError = nombreErr;
      _apellidoError = apellidoErr;
      _documentoError = documentoErr;
      _fechaNacimientoError = fechaErr;
      _emailError = emailErr;
      _telefonoError = telefonoErr;
    });
    return nombreErr == null &&
        apellidoErr == null &&
        documentoErr == null &&
        fechaErr == null &&
        emailErr == null &&
        telefonoErr == null;
  }

  bool _validatePaso2() {
    final passErr = validatePassword(_passwordController.text);
    final confirmErr = validatePasswordMatch(
      _confirmController.text,
      _passwordController.text,
    );
    final tcErr = _tcAcepted
        ? null
        : 'Tenés que aceptar los Términos y Condiciones.';
    setState(() {
      _passwordError = passErr;
      _confirmError = confirmErr;
      _tcError = tcErr;
      _generalError = null;
    });
    return passErr == null && confirmErr == null && tcErr == null;
  }

  // ── Selector de fecha ─────────────────────────────────────────────────────────

  Future<void> _pickFechaNacimiento() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _fechaNacimiento ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Seleccioná tu fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
        _fechaNacimientoError = null;
      });
    }
  }

  // ── Navegación de pasos ───────────────────────────────────────────────────────

  void _onContinuar() {
    if (_validatePaso1()) {
      setState(() => _currentStep = 2);
    }
  }

  /// Avanza del paso de identidad (2) al de credenciales (3). Exige la foto del
  /// documento (obligatoria).
  void _onContinuarPaso2() {
    if (_imagenDocumento == null) {
      setState(() {
        _imagenDocumentoError = 'Necesitamos la foto de tu documento.';
      });
      return;
    }
    setState(() => _currentStep = 3);
  }

  // ── Captura de fotos ──────────────────────────────────────────────────────────

  Future<void> _pickImagenPerfil() async {
    final base64 = await pickImageAsBase64(context);
    if (base64 == null || !mounted) return;
    setState(() => _imagenPerfil = base64);
  }

  Future<void> _pickImagenDocumento() async {
    final base64 = await pickDocumentImageAsBase64(context);
    if (base64 == null || !mounted) return;
    setState(() {
      _imagenDocumento = base64;
      _imagenDocumentoError = null;
      // Descarta un error de validación de identidad de un intento anterior.
      _generalError = null;
    });
  }

  Future<bool> _onWillPop() async {
    if (_currentStep == 3) {
      setState(() => _currentStep = 2);
      return false;
    }
    if (_currentStep == 2) {
      setState(() => _currentStep = 1);
      return false;
    }
    if (!_hasDatosPaso1) return true;
    final salir = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir del registro?'),
        content: const Text(
          'Si salís ahora, se perderán los datos que ingresaste.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    return salir ?? false;
  }

  // ── Submit ───────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_validatePaso2()) return;

    // Guardia defensiva: la foto del documento es obligatoria. Si faltara,
    // volver al paso de identidad (no debería ocurrir por el gating de UI).
    if (_imagenDocumento == null) {
      setState(() {
        _currentStep = 2;
        _imagenDocumentoError = 'Necesitamos la foto de tu documento.';
      });
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final result = await ref
        .read(authStateProvider.notifier)
        .register(
          RegistroData(
            nombre: _nombreController.text.trim(),
            apellido: _apellidoController.text.trim(),
            documento: _documentoController.text.trim(),
            fechaNacimiento: _fechaNacimiento!,
            email: email,
            telefono: _telefonoController.text.trim().isEmpty
                ? null
                : _telefonoController.text.trim(),
            contrasena: _passwordController.text,
            imagenDocumento: _imagenDocumento!,
            imagen: _imagenPerfil,
          ),
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      data: (_) {
        // La cuenta quedó creada. La foto del documento es PII: se limpia de
        // memoria antes de continuar.
        _imagenDocumento = null;
        // El backend crea la cuenta en estado pendiente de validación y envía
        // el primer código OTP por email. Se continúa a la verificación.
        context.goNamed(AppRoutes.verifyEmailName, extra: email);
      },
      error: (error, _) {
        if (error is CuentaExistenteException) {
          // Email duplicado: volver al paso 1 y marcar el campo.
          setState(() {
            _currentStep = 1;
            _emailError =
                'Este email ya está registrado. Intentá iniciar sesión.';
          });
        } else if (error is ServicioNoDisponibleException) {
          // Servicio de validación caído: no es error de datos del usuario.
          // Permanece en el paso final; puede reintentar con el mismo botón.
          setState(() {
            _generalError = error.mensaje;
            _generalErrorTone = BannerTone.warning;
          });
        } else if (error is ValidacionException) {
          // Identidad no validada (no coincide o ilegible). Volver al paso de
          // identidad para retomar la foto y limpiar la anterior (PII).
          setState(() {
            _currentStep = 2;
            _imagenDocumento = null;
            _imagenDocumentoError = null;
            _generalError = error.mensaje;
            _generalErrorTone = BannerTone.error;
          });
        } else if (error is SinConexionException) {
          setState(() {
            _generalError = 'Sin conexión. Verificá tu red e intentá de nuevo.';
            _generalErrorTone = BannerTone.error;
          });
        } else {
          setState(() {
            _generalError = 'Error al crear la cuenta. Intentá de nuevo.';
            _generalErrorTone = BannerTone.error;
          });
        }
      },
      loading: () {},
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) context.pop();
            },
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Volver',
          ),
          backgroundColor: context.colors.background,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: switch (_currentStep) {
              1 => _buildPaso1(),
              2 => _buildPaso2Identidad(),
              _ => _buildPaso3Credenciales(),
            },
          ),
        ),
      ),
    );
  }

  // ── Paso 1 ───────────────────────────────────────────────────────────────────

  Widget _buildPaso1() {
    final theme = Theme.of(context);

    // Formatea la fecha seleccionada como DD/MM/AAAA.
    String fechaFormateada = 'Seleccioná tu fecha de nacimiento';
    if (_fechaNacimiento != null) {
      final d = _fechaNacimiento!;
      fechaFormateada =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        StepProgressBar(currentStep: 1, totalSteps: 3),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Creá tu cuenta',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Empecemos con tus datos personales.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Foto de perfil (opcional)
        Center(
          child: EditableAvatar(
            nombre: _nombreController.text.isNotEmpty
                ? _nombreController.text
                : '?',
            imagen: imageProviderFromBase64(_imagenPerfil),
            onTap: _pickImagenPerfil,
            size: 88,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            'Foto de perfil (opcional)',
            style: theme.textTheme.labelSmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Nombre
        AppTextField(
          label: 'Nombre',
          hint: 'Ej. María',
          controller: _nombreController,
          errorText: _nombreError,
          focusNode: _nombreFocus,
          textCapitalization: TextCapitalization.words,
          prefixIcon: const Icon(Icons.person_outline, size: 20),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_apellidoFocus),
          onChanged: (_) {
            if (_nombreError != null) setState(() => _nombreError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Apellido
        AppTextField(
          label: 'Apellido',
          hint: 'Ej. González',
          controller: _apellidoController,
          errorText: _apellidoError,
          focusNode: _apellidoFocus,
          textCapitalization: TextCapitalization.words,
          prefixIcon: const Icon(Icons.person_outline, size: 20),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_documentoFocus),
          onChanged: (_) {
            if (_apellidoError != null) setState(() => _apellidoError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Documento (DNI)
        AppTextField(
          label: 'DNI',
          hint: 'Ej. 30123456',
          controller: _documentoController,
          errorText: _documentoError,
          focusNode: _documentoFocus,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.badge_outlined, size: 20),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            _documentoFocus.unfocus();
            _pickFechaNacimiento();
          },
          onChanged: (_) {
            if (_documentoError != null) setState(() => _documentoError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Fecha de nacimiento (date picker)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha de nacimiento',
              style: theme.textTheme.labelMedium?.copyWith(
                color: _fechaNacimientoError != null
                    ? context.colors.error
                    : context.colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickFechaNacimiento,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _fechaNacimientoError != null
                        ? context.colors.error
                        : context.colors.outline,
                    width: _fechaNacimientoError != null ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: _fechaNacimiento != null
                          ? context.colors.textPrimary
                          : context.colors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      fechaFormateada,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _fechaNacimiento != null
                            ? context.colors.textPrimary
                            : context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_fechaNacimientoError != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Text(
                  _fechaNacimientoError!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Email
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
          helperText: 'Lo usarás para iniciar sesión.',
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_telefonoFocus),
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Teléfono
        AppTextField(
          label: 'Teléfono',
          hint: '+54 9 11 1234 5678',
          controller: _telefonoController,
          errorText: _telefonoError,
          focusNode: _telefonoFocus,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined, size: 20),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _onContinuar(),
          onChanged: (_) {
            if (_telefonoError != null) setState(() => _telefonoError = null);
          },
        ),
        const SizedBox(height: AppSpacing.xxl),

        PrimaryButton(label: 'Continuar', onPressed: _onContinuar),
        const SizedBox(height: AppSpacing.md),

        Center(
          child: SecondaryTextButton(
            label: '¿Ya tenés cuenta? Iniciar sesión',
            onPressed: () => context.pushNamed(AppRoutes.loginName),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // ── Paso 2 · Identidad (foto del documento) ──────────────────────────────────

  Widget _buildPaso2Identidad() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        StepProgressBar(currentStep: 2, totalSteps: 3),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Verificá tu identidad',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Tomá una foto de tu DNI para confirmar que los datos coinciden con '
          'los que ingresaste.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        DocumentCaptureField(
          imagenBase64: _imagenDocumento,
          onCapture: _pickImagenDocumento,
          onRemove: () => setState(() => _imagenDocumento = null),
          errorText: _imagenDocumentoError,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Error general (ej. identidad no validada tras el submit).
        if (_generalError != null) ...[
          InlineErrorBanner(message: _generalError!, tone: _generalErrorTone),
          const SizedBox(height: AppSpacing.lg),
        ],

        PrimaryButton(label: 'Continuar', onPressed: _onContinuarPaso2),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // ── Paso 3 · Credenciales ─────────────────────────────────────────────────────

  Widget _buildPaso3Credenciales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        StepProgressBar(currentStep: 3, totalSteps: 3),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Creá tu contraseña',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Vas a usarla junto con tu email para entrar.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Contraseña
        AppTextField(
          label: 'Contraseña',
          hint: 'Ingresá tu contraseña',
          controller: _passwordController,
          errorText: _passwordError,
          focusNode: _passwordFocus,
          obscureText: !_showPassword,
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _showPassword = !_showPassword),
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
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_confirmFocus),
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
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
            tooltip: _showConfirm ? 'Ocultar contraseña' : 'Mostrar contraseña',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          onChanged: (_) {
            if (_confirmError != null) setState(() => _confirmError = null);
          },
        ),
        const SizedBox(height: AppSpacing.xl),

        // Checkbox T&C
        _TcCheckbox(
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
          InlineErrorBanner(message: _generalError!, tone: _generalErrorTone),
          const SizedBox(height: AppSpacing.lg),
        ],

        PrimaryButton(
          label: 'Crear cuenta',
          isLoading: _isLoading,
          onPressed: _submit,
        ),

        // La validación del documento puede demorar: se avisa para que no
        // parezca que la app se colgó.
        if (_isLoading) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Estamos verificando tu documento… esto puede demorar hasta un '
            'minuto.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

// ─── Widget de checkbox T&C ───────────────────────────────────────────────────

class _TcCheckbox extends StatelessWidget {
  const _TcCheckbox({
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
              Expanded(child: _TcText(onTermsTap: onTermsTap)),
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
                color: context.colors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Texto del checkbox con links inline.
class _TcText extends StatelessWidget {
  const _TcText({required this.onTermsTap});

  final VoidCallback onTermsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(
          color: context.colors.textPrimary,
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
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const TextSpan(text: ' y la '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onTermsTap,
              child: Text(
                'Política de Privacidad',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
