import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// US-12 · Alta de persona a cargo.
///
/// Formulario con Nombre, Apellido, DNI, Fecha de nacimiento, Email (opcional)
/// y checkbox T&C. El botón "Registrar persona" permanece deshabilitado hasta
/// que T&C esté marcado.
///
/// Si [dependentId] viene en la ruta, es edición (US-14 route /edit).
class DependentFormScreen extends ConsumerStatefulWidget {
  const DependentFormScreen({super.key, this.dependentId});

  final String? dependentId;

  @override
  ConsumerState<DependentFormScreen> createState() =>
      _DependentFormScreenState();
}

class _DependentFormScreenState extends ConsumerState<DependentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _dniController = TextEditingController();
  final _emailController = TextEditingController();

  String? _nombreError;
  String? _apellidoError;
  String? _dniError;
  String? _emailError;

  DateTime? _fechaNacimiento;
  bool _tcAceptado = false;
  bool _isLoading = false;

  // Estado de éxito
  bool _exitoso = false;
  String _nombreCreado = '';
  String _apellidoCreado = '';

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get _puedeEnviar => _tcAceptado && !_isLoading;

  String get _fechaTexto => _fechaNacimiento == null
      ? ''
      : DateFormat('dd/MM/yyyy').format(_fechaNacimiento!);

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _fechaNacimiento ?? DateTime(hoy.year - 30, hoy.month, hoy.day),
      firstDate: DateTime(1900),
      lastDate: hoy,
    );
    if (picked != null) {
      setState(() => _fechaNacimiento = picked);
    }
  }

  bool _validar() {
    final nombreErr = validateNombre(_nombreController.text);
    final apellidoErr = validateApellido(_apellidoController.text);
    final dniErr = validateDocumento(_dniController.text);
    String? fechaErr;
    if (_fechaNacimiento == null) {
      fechaErr = 'Seleccioná la fecha de nacimiento.';
    }
    String? emailErr;
    if (_emailController.text.trim().isNotEmpty) {
      emailErr = validateEmail(_emailController.text);
    }

    setState(() {
      _nombreError = nombreErr;
      _apellidoError = apellidoErr;
      _dniError = dniErr;
      _emailError = emailErr;
    });

    if (fechaErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(fechaErr), backgroundColor: AppColors.error),
      );
      return false;
    }

    return nombreErr == null &&
        apellidoErr == null &&
        dniErr == null &&
        emailErr == null;
  }

  Future<void> _submit() async {
    if (!_validar()) return;
    setState(() => _isLoading = true);

    try {
      final crearDependente = ref.read(crearDependenteProvider);
      await crearDependente(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        documento: _dniController.text.trim().replaceAll(RegExp(r'\D'), ''),
        fechaNacimiento: _fechaNacimiento!,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _exitoso = true;
        _nombreCreado = _nombreController.text.trim();
        _apellidoCreado = _apellidoController.text.trim();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _exitoso = false;
      _nombreController.clear();
      _apellidoController.clear();
      _dniController.clear();
      _emailController.clear();
      _fechaNacimiento = null;
      _tcAceptado = false;
      _nombreError = null;
      _apellidoError = null;
      _dniError = null;
      _emailError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_exitoso) {
      return SuccessView(
        title: '¡Persona registrada!',
        highlightedName: '$_nombreCreado $_apellidoCreado',
        subtitle: ' fue agregado a tu lista de personas a cargo.',
        primaryButtonLabel: 'Ver personas a cargo',
        onPrimaryTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(AppRoutes.dependentsName);
          }
        },
        secondaryButtonLabel: 'Agregar otra persona',
        onSecondaryTap: _resetForm,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          widget.dependentId == null
              ? 'Nueva persona a cargo'
              : 'Editar persona a cargo',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subtítulo
              Text(
                'Completá los datos de la persona que vas a registrar.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Bloque de foto (placeholder)
              Center(
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                      onTap: () {
                        // TODO(MVP): integrar image_picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Funcionalidad disponible próximamente.',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.outline,
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          size: 24,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Agregar foto',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Campo Nombre
              AppTextField(
                label: 'Nombre *',
                hint: 'Ej. Juan',
                controller: _nombreController,
                errorText: _nombreError,
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_nombreError != null) {
                    setState(() => _nombreError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Campo Apellido
              AppTextField(
                label: 'Apellido *',
                hint: 'Ej. García',
                controller: _apellidoController,
                errorText: _apellidoError,
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_apellidoError != null) {
                    setState(() => _apellidoError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Campo DNI
              AppTextField(
                label: 'Documento (DNI) *',
                hint: 'Ej. 12.345.678',
                controller: _dniController,
                errorText: _dniError,
                prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_dniError != null) setState(() => _dniError = null);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Campo Fecha de nacimiento (tap abre DatePicker)
              GestureDetector(
                onTap: _seleccionarFecha,
                child: AbsorbPointer(
                  child: AppTextField(
                    label: 'Fecha de nacimiento *',
                    hint: 'DD/MM/AAAA',
                    controller: TextEditingController(text: _fechaTexto),
                    prefixIcon: const Icon(
                      Icons.calendar_month_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Campo Email (opcional)
              AppTextField(
                label: 'Email (opcional)',
                hint: 'juan@ejemplo.com',
                controller: _emailController,
                errorText: _emailError,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Checkbox T&C
              _TcCheckboxRow(
                accepted: _tcAceptado,
                onChanged: (v) => setState(() => _tcAceptado = v ?? false),
                onTermsTap: () async {
                  final accepted = await TermsBottomSheet.show(context);
                  if (accepted == true) setState(() => _tcAceptado = true);
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Botón registrar
              PrimaryButton(
                label: 'Registrar persona',
                isLoading: _isLoading,
                onPressed: _puedeEnviar ? _submit : null,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Checkbox T&C local ───────────────────────────────────────────────────────

class _TcCheckboxRow extends StatelessWidget {
  const _TcCheckboxRow({
    required this.accepted,
    required this.onChanged,
    required this.onTermsTap,
  });

  final bool accepted;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTermsTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!accepted),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Row(
        children: [
          Checkbox(value: accepted, onChanged: onChanged),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                children: [
                  const TextSpan(text: 'Acepto los '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: onTermsTap,
                      child: Text(
                        'Términos y Condiciones',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
