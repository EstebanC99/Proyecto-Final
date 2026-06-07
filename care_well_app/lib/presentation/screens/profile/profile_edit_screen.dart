import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// US-07 · Edición del perfil del usuario autenticado.
///
/// Edición inline campo a campo con [ProfileDataRow]. Cada campo guarda
/// de forma independiente al confirmar. No hay botón "Guardar todo".
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  bool _isLoading = false;

  Future<void> _guardarEmail(String nuevoEmail) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authStateProvider.notifier)
          .actualizarPerfil(email: nuevoEmail);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos actualizados correctamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarTelefono(String nuevoTelefono) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authStateProvider.notifier)
          .actualizarPerfil(telefono: nuevoTelefono);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos actualizados correctamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarDocumento(String nuevoDocumento) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authStateProvider.notifier)
          .actualizarPerfil(documento: nuevoDocumento);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos actualizados correctamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final rol = ref.watch(rolEnSistemaProvider);

    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: const Text('Mi Perfil'),
        ),
        body: authState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: InlineErrorBanner(message: error.toString()),
          ),
          data: (usuario) {
            if (usuario == null) return const SizedBox.shrink();

            final persona = usuario.persona;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Encabezado de perfil (solo lectura)
                  Container(
                    width: double.infinity,
                    color: AppColors.surface,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        ProfileAvatar(nombre: persona.nombre),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          persona.nombreCompleto,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        RoleBadge(rol: rol),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.outline,
                  ),

                  // Email — editable
                  ProfileDataRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: persona.email ?? '',
                    editable: true,
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                    onSave: _guardarEmail,
                  ),

                  // Teléfono — editable
                  ProfileDataRow(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: persona.telefono ?? '',
                    editable: true,
                    keyboardType: TextInputType.phone,
                    validator: validateTelefono,
                    onSave: _guardarTelefono,
                  ),

                  // DNI — editable
                  ProfileDataRow(
                    icon: Icons.badge_outlined,
                    label: 'DNI',
                    value: persona.documento ?? '',
                    editable: true,
                    keyboardType: TextInputType.number,
                    onSave: _guardarDocumento,
                  ),

                  // Rol — solo lectura (sin lápiz)
                  ProfileDataRow(
                    icon: Icons.person_outlined,
                    label: 'Rol en el sistema',
                    value: rol,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
