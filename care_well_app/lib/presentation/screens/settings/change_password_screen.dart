import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/routers/app_navigation.dart';
import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/exceptions/exceptions.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// US-09 · Cambio de contraseña para el usuario autenticado.
///
/// La sesión se mantiene activa tras el cambio exitoso; al confirmarlo se
/// muestra un [SuccessView] con el CTA para volver a Configuración.
///
/// ## Validación
/// No usa `Form`/`GlobalKey<FormState>`: con el CTA fijo al pie
/// ([FormBottomBar]) la validación vive en el estado de la pantalla, igual que
/// en `ResetPasswordScreen`. El botón queda siempre habilitado y valida al
/// tocarlo, así cada problema se explica como `errorText` bajo su propio campo
/// (en vez de retar al usuario antes del primer intento).
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _actualController = TextEditingController();
  final _nuevaController = TextEditingController();
  final _confirmarController = TextEditingController();

  final _actualFocus = FocusNode();
  final _nuevaFocus = FocusNode();
  final _confirmarFocus = FocusNode();

  bool _mostrarActual = false;
  bool _mostrarNueva = false;
  bool _mostrarConfirmar = false;

  bool _isLoading = false;
  bool _exitoso = false;

  String? _errorActual;
  String? _errorNueva;
  String? _errorConfirmar;
  String? _errorGeneral;

  @override
  void dispose() {
    _actualController.dispose();
    _nuevaController.dispose();
    _confirmarController.dispose();
    _actualFocus.dispose();
    _nuevaFocus.dispose();
    _confirmarFocus.dispose();
    super.dispose();
  }

  /// Hay algo que perder si ya se escribió en cualquiera de los tres campos.
  bool get _hayCambios =>
      _actualController.text.isNotEmpty ||
      _nuevaController.text.isNotEmpty ||
      _confirmarController.text.isNotEmpty;

  // ── Validación local ─────────────────────────────────────────────────────────

  /// Valida los tres campos y deja el mensaje concreto bajo cada uno.
  ///
  /// Devuelve `true` si se puede seguir con el guardado.
  bool _validar() {
    // La contraseña ACTUAL se valida sólo como requerida, a propósito: no se le
    // aplica `validatePassword` porque una cuenta creada antes del mínimo de 8
    // caracteres tiene hoy una contraseña más corta y quedaría sin poder
    // cambiarla nunca. La exigencia de complejidad rige sobre la NUEVA.
    final actualError = _actualController.text.isEmpty
        ? 'Ingresá tu contraseña actual.'
        : null;
    // La nueva pasa por el mismo validador que el alta de la cuenta.
    final nuevaError = validatePassword(_nuevaController.text);
    final confirmarError = validatePasswordMatch(
      _confirmarController.text,
      _nuevaController.text,
    );

    setState(() {
      _errorActual = actualError;
      _errorNueva = nuevaError;
      _errorConfirmar = confirmarError;
      _errorGeneral = null;
    });

    // El foco va al primer campo con problema: además de ahorrar el scroll, es
    // lo que hace que un lector de pantalla anuncie el `errorText`.
    FocusNode? primerProblema;
    if (actualError != null) {
      primerProblema = _actualFocus;
    } else if (nuevaError != null) {
      primerProblema = _nuevaFocus;
    } else if (confirmarError != null) {
      primerProblema = _confirmarFocus;
    }
    primerProblema?.requestFocus();

    return primerProblema == null;
  }

  // ── Guardado ─────────────────────────────────────────────────────────────────

  Future<void> _guardar() async {
    if (!_validar()) return;

    setState(() {
      _isLoading = true;
      _errorGeneral = null;
    });

    try {
      await ref
          .read(authStateProvider.notifier)
          .cambiarContrasena(
            contrasenaActual: _actualController.text,
            nuevaContrasena: _nuevaController.text,
          );
      if (mounted) setState(() => _exitoso = true);
    } catch (error) {
      // `catch` sin filtro de tipo (y no `on Exception`): el datasource de la
      // API todavía lanza `UnimplementedError` —un `Error`, no una
      // `Exception`— porque el endpoint está pendiente en el backend. Con el
      // filtro, esa falla escapaba y dejaba el botón cargando para siempre.
      if (!mounted) return;
      setState(() {
        if (error is SinConexionException) {
          _errorGeneral = 'Sin conexión. Verificá tu red e intentá de nuevo.';
        } else if (error is Exception && _esContrasenaIncorrecta(error)) {
          _errorActual = 'Contraseña incorrecta';
        } else {
          // Cualquier otra falla se explica en términos del usuario: el texto
          // crudo de un error técnico no se muestra en pantalla.
          _errorGeneral = 'No pudimos cambiar tu contraseña. Intentá de nuevo.';
        }
      });
    } finally {
      // Siempre, pase lo que pase: ninguna falla puede dejar el CTA girando.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Reconoce el rechazo del backend por contraseña actual equivocada, para
  /// mostrarlo en el campo que lo causó y no como error general.
  bool _esContrasenaIncorrecta(Exception error) {
    final mensaje = error
        .toString()
        .replaceFirst('Exception: ', '')
        .toLowerCase();
    return mensaje.contains('incorrecta') || mensaje.contains('actual');
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_exitoso) {
      // Sin el guard: después de guardar no queda nada que perder.
      return SuccessView(
        title: 'Contraseña actualizada',
        subtitle: 'Tu nueva contraseña ya está activa.',
        primaryButtonLabel: 'Volver a Configuración',
        onPrimaryTap: () => context.volverA(AppRoutes.settings),
      );
    }

    // El guard sale con `Navigator.pop`: la pantalla se abre con `pushNamed`
    // desde Configuración, así que siempre hay una ruta debajo.
    return UnsavedChangesGuard(
      hayCambios: () => _hayCambios,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.surface,
          // Sin `leading` propio: el back de Material llama a `maybePop`, que
          // es lo que hace pasar la salida por el guard. Un `context.pop()` a
          // mano lo saltearía.
          title: const Text('Cambiar contraseña'),
        ),
        body: SafeArea(
          // Sin padding de teclado: ya lo suma `FormBottomBar`.
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actualizá tu contraseña',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tu nueva contraseña reemplazará la actual.',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                  ),
                ),

                // El error general va arriba, no al pie del scroll: el CTA está
                // fijo en la barra inferior, así que un banner al final podría
                // quedar fuera de vista justo cuando hace falta leerlo.
                if (_errorGeneral != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  InlineErrorBanner(message: _errorGeneral!),
                ],

                _PasswordField(
                  label: 'Contraseña actual',
                  hint: 'Ingresá tu contraseña actual',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  controller: _actualController,
                  focusNode: _actualFocus,
                  errorText: _errorActual,
                  enabled: !_isLoading,
                  obscure: !_mostrarActual,
                  onToggleObscure: () =>
                      setState(() => _mostrarActual = !_mostrarActual),
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _nuevaFocus.requestFocus(),
                  onChanged: (_) {
                    if (_errorActual != null) {
                      setState(() => _errorActual = null);
                    }
                  },
                ),

                _PasswordField(
                  label: 'Nueva contraseña',
                  hint: 'Ingresá tu nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  controller: _nuevaController,
                  focusNode: _nuevaFocus,
                  errorText: _errorNueva,
                  // El medidor de fortaleza sólo aparece con texto: con el
                  // campo vacío, la exigencia se dice acá.
                  helperText: _errorNueva == null
                      ? 'Mínimo 8 caracteres.'
                      : null,
                  enabled: !_isLoading,
                  obscure: !_mostrarNueva,
                  onToggleObscure: () =>
                      setState(() => _mostrarNueva = !_mostrarNueva),
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _confirmarFocus.requestFocus(),
                  onChanged: (_) {
                    if (_errorNueva != null) {
                      setState(() => _errorNueva = null);
                    }
                  },
                ),
                // El medidor se suscribe al controller: se actualiza al tipear
                // sin redibujar el resto del formulario.
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nuevaController,
                  builder: (context, valor, _) => valor.text.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: PasswordStrengthMeter(password: valor.text),
                        ),
                ),

                _PasswordField(
                  label: 'Confirmar nueva contraseña',
                  hint: 'Repetí tu nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  controller: _confirmarController,
                  focusNode: _confirmarFocus,
                  errorText: _errorConfirmar,
                  enabled: !_isLoading,
                  obscure: !_mostrarConfirmar,
                  onToggleObscure: () =>
                      setState(() => _mostrarConfirmar = !_mostrarConfirmar),
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _guardar(),
                  onChanged: (_) {
                    if (_errorConfirmar != null) {
                      setState(() => _errorConfirmar = null);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: FormBottomBar(
          label: 'Guardar cambios',
          accent: context.colors.primary,
          loading: _isLoading,
          onPressed: _guardar,
          // Sin `hint`: los tres problemas posibles tienen un campo propio
          // donde mostrarse. El hint queda para lo que no tiene campo.
        ),
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

/// Variante de credencial del campo de formulario del ciclo.
///
/// Mismo rótulo en versalitas que [FormTextField] —el lenguaje visual de los
/// formularios rediseñados— pero **sin contador de caracteres**, que revelaría
/// la longitud de la contraseña a quien mire la pantalla, y **con
/// `obscureText` + ojo** para mostrarla u ocultarla.
///
/// No define estilo propio: el borde, el relleno y los colores salen del
/// `inputDecorationTheme`, igual que en `AppTextField`. Si en algún momento
/// parece más simple reemplazarlo por [FormTextField] (vuelve el contador) o
/// por `AppTextField` (vuelve el rótulo en otro estilo), es que se perdió el
/// motivo por el que existe.
class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    this.hint,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.focusNode,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.prefixIcon,
  });

  /// Rótulo del campo. Se dibuja con [SectionLabel] (siempre obligatorio).
  final String label;

  final TextEditingController controller;

  /// `true` oculta el texto tipeado.
  final bool obscure;

  /// Alterna [obscure]. Lo dispara el ojo del final del campo.
  final VoidCallback onToggleObscure;

  final String? hint;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: label, required: true),
        TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          obscureText: obscure,
          // Un teclado que corrige o sugiere sobre una contraseña sólo mete
          // ruido (y la filtra al diccionario del sistema).
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: autofillHints,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            errorText: errorText,
            helperText: helperText,
            suffixIcon: IconButton(
              onPressed: enabled ? onToggleObscure : null,
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: context.colors.textSecondary,
              ),
              tooltip: obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
            ),
          ),
        ),
      ],
    );
  }
}
