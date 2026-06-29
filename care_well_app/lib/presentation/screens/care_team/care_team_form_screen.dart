import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Tipo de formulario: agregar Responsable (US-17) o Cuidador (US-20).
enum CareTeamFormType { responsible, caregiver }

/// US-17/20 · Alta de responsable / cuidador.
///
/// Formulario con campo Email y sección de Permisos con toggles.
/// Los permisos por defecto son: todos ON para Responsable,
/// verFichaSalud + gestionarAgenda ON para Cuidador.
class CareTeamFormScreen extends ConsumerStatefulWidget {
  const CareTeamFormScreen({super.key, required this.formType});

  final CareTeamFormType formType;

  @override
  ConsumerState<CareTeamFormScreen> createState() => _CareTeamFormScreenState();
}

class _CareTeamFormScreenState extends ConsumerState<CareTeamFormScreen> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _isLoading = false;

  // Estado de éxito
  bool _exitoso = false;
  String _emailAgregado = '';
  String _personaNombre = '';

  /// Mapa de permisos por id: true = activo, false = inactivo.
  late Map<int, bool> _permisos;

  bool get _esResponsable => widget.formType == CareTeamFormType.responsible;

  @override
  void initState() {
    super.initState();
    // _permisos se inicializa en build() cuando ya se tienen los códigos del provider.
    // Aquí solo inicializamos vacío; se llenará la primera vez en build.
    _permisos = {};
  }

  Map<int, bool> _permisosDefault(List<PermisoCuidado> permisos) {
    if (_esResponsable) {
      return {for (final c in permisos) c.id: true};
    } else {
      // Cuidador: solo verFichaSalud y gestionarAgenda ON por defecto.
      return {
        for (final c in permisos)
          c.id:
              c.id == PermisosCuidadoConst.verFichaSalud ||
              c.id == PermisosCuidadoConst.gestionarAgenda,
      };
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailErr = validateEmail(_emailController.text);
    setState(() => _emailError = emailErr);
    if (emailErr != null) return;

    setState(() => _isLoading = true);

    try {
      final personaCtx = await ref.read(
        personaVisualizacionSeleccionadaProvider.future,
      );
      if (personaCtx == null) {
        throw Exception('No hay persona de contexto.');
      }

      final crearMiembro = ref.read(crearMiembroProvider);
      final todosLosCodigos = ref.read(availablePermisosProvider);
      final permisosActivos = todosLosCodigos
          .where((c) => _permisos[c.id] == true)
          .toList();

      // Construimos un RolCuidado con el id correcto; el provider lo busca por id.
      final rolCuidado = RolCuidado(
        id: _esResponsable
            ? RolesCuidadoConst.responsable
            : RolesCuidadoConst.cuidador,
        descripcion: _esResponsable ? 'Responsable' : 'Cuidador',
      );

      await crearMiembro(
        personaCuidadaId: personaCtx.id,
        email: _emailController.text.trim(),
        permisos: permisosActivos,
        rol: rolCuidado,
      );

      if (!mounted) return;
      setState(() {
        _exitoso = true;
        _emailAgregado = _emailController.text.trim();
        _personaNombre = personaCtx.nombreCompleto;
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

  @override
  Widget build(BuildContext context) {
    if (_exitoso) {
      final personaCtxAsync = ref.watch(
        personaVisualizacionSeleccionadaProvider,
      );

      return SuccessView(
        title: 'Solicitud enviada',
        highlightedName: _emailAgregado,
        subtitle:
            ' recibirá la solicitud para unirse al equipo de cuidado de '
            '$_personaNombre.',
        primaryButtonLabel: 'Volver al equipo',
        onPrimaryTap: () {
          // Invalidar para forzar recarga al volver.
          personaCtxAsync.whenData((p) {
            if (p != null) {
              ref.invalidate(asignacionesPorPersonaCuidadaProvider(p.id));
            }
          });
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(AppRoutes.careTeamName);
          }
        },
      );
    }

    final personaCtxAsync = ref.watch(personaVisualizacionSeleccionadaProvider);
    final personaNombre = personaCtxAsync.valueOrNull?.nombreCompleto ?? '...';

    final title = _esResponsable ? 'Agregar responsable' : 'Agregar cuidador';
    final headerBody = _esResponsable
        ? 'El responsable podrá gestionar datos y coordinar el cuidado de'
        : 'El cuidador tendrá acceso según los permisos que definas para';

    final todosLosCodigos = ref.watch(availablePermisosProvider);
    // Inicializar permisos la primera vez que los códigos están disponibles.
    if (_permisos.isEmpty && todosLosCodigos.isNotEmpty) {
      _permisos = _permisosDefault(todosLosCodigos);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Subtítulo de contexto
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(text: '$headerBody '),
                  TextSpan(
                    text: '$personaNombre.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Campo Email
            AppTextField(
              label: _esResponsable
                  ? 'Email del responsable'
                  : 'Email del cuidador',
              hint:
                  'email del nuevo ${_esResponsable ? 'responsable' : 'cuidador'}',
              controller: _emailController,
              errorText: _emailError,
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              onChanged: (_) {
                if (_emailError != null) setState(() => _emailError = null);
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // Bloque de permisos
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header del bloque
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      14,
                      AppSpacing.lg,
                      10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Permisos asignados',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _esResponsable
                              ? 'El responsable obtiene acceso completo. Podés ajustarlo después.'
                              : 'Definí qué puede hacer el cuidador. Podés ajustarlo después.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.surfaceVariant,
                  ),
                  // Filas de permisos
                  ...todosLosCodigos.asMap().entries.map((entry) {
                    final i = entry.key;
                    final permiso = entry.value;
                    return Column(
                      children: [
                        PermissionToggleRow(
                          label: permiso.descripcion,
                          value: _permisos[permiso.id] ?? false,
                          onChanged: (v) =>
                              setState(() => _permisos[permiso.id] = v),
                        ),
                        if (i < todosLosCodigos.length - 1)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            indent: AppSpacing.lg,
                            endIndent: AppSpacing.lg,
                            color: AppColors.surfaceVariant,
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Botón Agregar
            PrimaryButton(
              label: _esResponsable
                  ? 'Agregar responsable'
                  : 'Agregar cuidador',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
