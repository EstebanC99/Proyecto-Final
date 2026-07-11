import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
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

  /// Preview local de la foto recién elegida (base64), para reflejarla al
  /// instante en el avatar de esta pantalla mientras se persiste y se recarga
  /// `personaImagenProvider`.
  String? _imagenPreview;

  /// Persiste los cambios de la persona propia contra el backend.
  ///
  /// El backend reemplaza `Imagen` incondicionalmente, así que si no se eligió
  /// una foto nueva hay que reenviar la existente para no borrarla. La imagen
  /// actual se resuelve desde `personaImagenProvider(...).future` (no `.value`,
  /// para no capturar `null` mientras está en loading).
  Future<void> _guardarPersona(
    Persona actual, {
    String? telefono,
    String? documento,
    String? nuevaImagenBase64,
  }) async {
    setState(() => _isLoading = true);
    try {
      // Preserva la foto existente si no se eligió una nueva (el backend
      // reemplaza Imagen incondicionalmente: null borraría la foto).
      String? imagenB64 = nuevaImagenBase64;
      if (imagenB64 == null) {
        final bytes = await ref.read(personaImagenProvider(actual.id).future);
        if (bytes != null) imagenB64 = base64Encode(bytes);
      }
      final actualizada = actual.copyWith(
        telefono: telefono,
        documento: documento,
        imagen: imagenB64,
      );
      final guardada = await ref
          .read(personaRepositoryProvider)
          .actualizar(actualizada);
      ref.read(authStateProvider.notifier).actualizarPersonaEnSesion(guardada);
      if (nuevaImagenBase64 != null) {
        ref.invalidate(personaImagenProvider(actual.id));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos actualizados correctamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _seleccionarImagen(Persona persona) async {
    final base64 = await pickImageAsBase64(context);
    if (base64 == null || !mounted) return;
    // Muestra la nueva foto al instante y la persiste contra el backend.
    setState(() => _imagenPreview = base64);
    await _guardarPersona(persona, nuevaImagenBase64: base64);
  }

  Future<void> _guardarTelefono(Persona persona, String nuevoTelefono) =>
      _guardarPersona(persona, telefono: nuevoTelefono);

  Future<void> _guardarDocumento(Persona persona, String nuevoDocumento) =>
      _guardarPersona(persona, documento: nuevoDocumento);

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

            // Preview local recién elegido; si no hay, la foto actual desde
            // el backend.
            final imagenRed = ref
                .watch(personaImagenProvider(persona.id))
                .value;
            final imagenAvatar =
                imageProviderFromBase64(_imagenPreview) ??
                (imagenRed != null ? MemoryImage(imagenRed) : null);

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
                        EditableAvatar(
                          nombre: persona.nombre,
                          imagen: imagenAvatar,
                          onTap: () => _seleccionarImagen(persona),
                        ),
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

                  // Email — solo lectura. Es concern de credenciales/Usuario y
                  // aún no tiene endpoint de modificación en el backend.
                  ProfileDataRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: persona.email ?? '',
                  ),

                  // Teléfono — editable
                  ProfileDataRow(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: persona.telefono ?? '',
                    editable: true,
                    keyboardType: TextInputType.phone,
                    validator: validateTelefono,
                    onSave: (v) => _guardarTelefono(persona, v),
                  ),

                  // DNI — editable
                  ProfileDataRow(
                    icon: Icons.badge_outlined,
                    label: 'DNI',
                    value: persona.documento,
                    editable: true,
                    keyboardType: TextInputType.number,
                    onSave: (v) => _guardarDocumento(persona, v),
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
