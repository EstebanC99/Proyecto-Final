import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// US-06 / US-07 · Perfil del usuario autenticado.
///
/// Una sola pantalla para ver y editar: los datos se modifican donde se leen.
/// El teléfono, el DNI y la fecha de nacimiento se editan campo a campo en la
/// misma fila; el nombre y el apellido, juntos, en una hoja inferior (van de a
/// pares para no dejar un estado intermedio con el nombre nuevo y el apellido
/// viejo). La foto se cambia desde el badge del encabezado.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
    String? nombre,
    String? apellido,
    String? telefono,
    String? documento,
    DateTime? fechaNacimiento,
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
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        documento: documento,
        fechaNacimiento: fechaNacimiento,
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

  /// Abre la hoja de nombre y apellido y persiste ambos campos de una sola vez.
  Future<void> _editarNombre(Persona persona) async {
    final resultado = await mostrarEditarNombreSheet(
      context,
      nombre: persona.nombre,
      apellido: persona.apellido,
    );
    if (resultado == null || !mounted) return;
    // Sin cambios reales no se molesta al backend.
    if (resultado.nombre == persona.nombre &&
        resultado.apellido == persona.apellido) {
      return;
    }
    await _guardarPersona(
      persona,
      nombre: resultado.nombre,
      apellido: resultado.apellido,
    );
  }

  Future<void> _guardarTelefono(Persona persona, String nuevoTelefono) =>
      _guardarPersona(persona, telefono: nuevoTelefono);

  Future<void> _guardarDocumento(Persona persona, String nuevoDocumento) =>
      _guardarPersona(persona, documento: nuevoDocumento);

  Future<void> _guardarFechaNacimiento(Persona persona, DateTime nuevaFecha) =>
      _guardarPersona(persona, fechaNacimiento: nuevaFecha);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final esClaro = Theme.of(context).brightness == Brightness.light;
    final authState = ref.watch(authStateProvider);

    return PopScope(
      // Mientras se persiste no se sale: el guardado ya está en vuelo.
      canPop: !_isLoading,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          // Sólido y del color de arranque del hero: los dos se leen como una
          // sola pieza, sin el borde que dejaría un AppBar transparente.
          backgroundColor: esClaro ? colors.primary : colors.surfaceVariant,
          foregroundColor: esClaro ? colors.onPrimary : colors.textPrimary,
          elevation: 0,
          title: const Text('Mi perfil'),
        ),
        body: authState.when(
          loading: () => const _ProfileSkeleton(),
          error: (error, _) => _ProfileError(
            message: error.toString(),
            onRetry: () => ref.invalidate(authStateProvider),
          ),
          data: (usuario) {
            if (usuario == null) return const SizedBox.shrink();
            return _contenido(usuario.persona);
          },
        ),
      ),
    );
  }

  Widget _contenido(Persona persona) {
    final sinAnimacion = MediaQuery.disableAnimationsOf(context);

    Widget anim(Widget child, int delayMs) => sinAnimacion
        ? child
        : FadeInUp(
            delay: Duration(milliseconds: delayMs),
            child: child,
          );

    // Preview local recién elegido; si no hay, la foto actual desde el backend.
    final imagenRed = ref.watch(personaImagenProvider(persona.id)).value;
    final imagenAvatar =
        imageProviderFromBase64(_imagenPreview) ??
        (imagenRed != null ? MemoryImage(imagenRed) : null);

    return ListView(
      // El hero llega a los bordes: el margen lateral lo pone cada bloque.
      padding: EdgeInsets.zero,
      children: [
        anim(
          ProfileHero(
            persona: persona,
            rol: ref.watch(rolEnSistemaProvider),
            imagen: imagenAvatar,
            onEditarNombre: () => _editarNombre(persona),
            onVerFoto: () {
              if (imagenAvatar != null) {
                ImageViewerDialog.show(context, imagenAvatar);
              }
            },
            onCambiarFoto: () => _seleccionarImagen(persona),
          ),
          0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: anim(
            // La tarjeta monta sobre el hero. El Transform no cambia el
            // layout, así que los 30dp que sube quedan como aire de más abajo:
            // se compensan sacándole el margen superior al rótulo siguiente.
            Container(
              transform: Matrix4.translationValues(0, -30, 0),
              child: StatsPerfilCard(stats: ref.watch(statsPerfilProvider)),
            ),
            50,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: anim(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionLabel(
                  text: 'Datos de contacto',
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                ),
                CardGroup(
                  children: [
                    // Email — solo lectura. Es concern de credenciales/Usuario
                    // y aún no tiene endpoint de modificación en el backend.
                    ProfileDataRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: persona.email ?? '',
                    ),
                    ProfileDataRow(
                      icon: Icons.phone_outlined,
                      label: 'Teléfono',
                      value: persona.telefono ?? '',
                      editable: true,
                      keyboardType: TextInputType.phone,
                      validator: validateTelefono,
                      onSave: (v) => _guardarTelefono(persona, v),
                    ),
                  ],
                ),
              ],
            ),
            100,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: anim(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionLabel(text: 'Identificación'),
                CardGroup(
                  children: [
                    ProfileDataRow(
                      icon: Icons.badge_outlined,
                      label: 'DNI',
                      value: persona.documento,
                      editable: true,
                      keyboardType: TextInputType.number,
                      validator: validateDocumento,
                      onSave: (v) => _guardarDocumento(persona, v),
                    ),
                    ProfileDateRow(
                      icon: Icons.cake_outlined,
                      label: 'Fecha de nacimiento',
                      value: persona.fechaNacimiento,
                      onSave: (v) => _guardarFechaNacimiento(persona, v),
                    ),
                  ],
                ),
              ],
            ),
            150,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

/// Skeleton de carga del perfil.
///
/// Estático a propósito (bloques planos, sin shimmer ni spinner): una animación
/// infinita colgaría los `pumpAndSettle()` de los tests y no aporta
/// información. Repite la silueta real —hero, cifras y dos grupos— para que la
/// transición loading → data no mueva el layout.
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final esClaro = Theme.of(context).brightness == Brightness.light;

    return ExcludeSemantics(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            color: esClaro ? colors.primary : colors.surfaceVariant,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 180,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 110,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
              height: 64,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: AppSpacing.elev1,
              ),
            ),
          ),
          for (var grupo = 0; grupo < 2; grupo++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: grupo == 0 ? 0 : AppSpacing.xl,
                      bottom: AppSpacing.sm,
                    ),
                    child: const _BloqueGris(width: 120, height: 12),
                  ),
                  CardGroup(
                    children: [
                      for (var fila = 0; fila < 2; fila++)
                        Container(
                          constraints: const BoxConstraints(minHeight: 64),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: colors.outline,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _BloqueGris(width: 60, height: 12),
                                    SizedBox(height: 4),
                                    _BloqueGris(width: 140, height: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Bloque plano del skeleton.
class _BloqueGris extends StatelessWidget {
  const _BloqueGris({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.outline,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
    );
  }
}

/// Banner de error inline para el perfil.
class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InlineErrorBanner(
            message: 'No se pudieron cargar los datos. $message',
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
