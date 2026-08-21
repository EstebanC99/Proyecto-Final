import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/profile/profile_providers.dart';
import 'profile_hero_avatar.dart';

/// Encabezado de "Mi perfil": foto, nombre y rol sobre una banda a todo el
/// ancho.
///
/// Es presentación pura: recibe la persona, el `AsyncValue` del rol y la foto
/// ya resueltos, y devuelve las acciones por callback (mismo criterio que
/// `SettingsUserCard`). No lee providers ni persiste nada.
class ProfileHero extends StatelessWidget {
  const ProfileHero({
    super.key,
    required this.persona,
    required this.rol,
    required this.imagen,
    required this.onEditarNombre,
    required this.onVerFoto,
    required this.onCambiarFoto,
  });

  /// Persona del usuario autenticado.
  final Persona persona;

  /// Rol del usuario en el sistema, tal como lo devuelve `rolEnSistemaProvider`.
  final AsyncValue<RolEnSistema?> rol;

  /// Foto de perfil ya resuelta. `null` = sin foto.
  final ImageProvider? imagen;

  /// Abre la hoja de edición de nombre y apellido.
  final VoidCallback onEditarNombre;

  /// Abre el visor de la foto de perfil.
  final VoidCallback onVerFoto;

  /// Abre el selector de origen de una foto nueva.
  final VoidCallback onCambiarFoto;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final esClaro = Theme.of(context).brightness == Brightness.light;
    final onHero = esClaro ? colors.onPrimary : colors.textPrimary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // En claro el hero repite el degradado de la card de resumen; en
        // oscuro un degradado sobre el primario satura, así que va plano.
        gradient: esClaro
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, colors.primaryHover],
              )
            : null,
        color: esClaro ? null : colors.surfaceVariant,
      ),
      child: Stack(
        // Los círculos decorativos se recortan contra los bordes del hero: sin
        // esto se derramarían sobre el resto de la pantalla.
        clipBehavior: Clip.hardEdge,
        children: [
          _CirculoDecorativo(
            diametro: 170,
            opacidad: esClaro ? 0.07 : 0.04,
            top: -60,
            right: -40,
          ),
          _CirculoDecorativo(
            diametro: 150,
            opacidad: esClaro ? 0.05 : 0.03,
            bottom: -70,
            left: -50,
          ),
          // El `SizedBox` no es redundante: un hijo NO posicionado de un
          // `Stack` recibe constraints sueltas y se ubica según
          // `Stack.alignment`, que por defecto es `topStart`. Sin él la
          // `Column` se encoge al ancho de su hijo más ancho y el bloque
          // entero queda pegado a la izquierda, por más que sus hijos estén
          // centrados dentro de ese ancho.
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                // Explícito aunque sea el valor por defecto: el bug que
                // corrigió este `SizedBox` demuestra que acá conviene que se
                // lea la intención.
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProfileHeroAvatar(
                    nombre: persona.nombre,
                    imagen: imagen,
                    onVerFoto: onVerFoto,
                    onCambiarFoto: onCambiarFoto,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FilaNombre(
                    nombre: persona.nombreCompleto,
                    color: onHero,
                    onTap: onEditarNombre,
                  ),
                  _ZonaRol(rol: rol, esClaro: esClaro),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nombre completo con el lápiz al lado, dentro de un único área tocable.
class _FilaNombre extends StatelessWidget {
  const _FilaNombre({
    required this.nombre,
    required this.color,
    required this.onTap,
  });

  final String nombre;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      // El nombre forma parte de la lectura: los demás nodos del hero anuncian
      // acciones ("Ver foto de perfil") o el rol, así que sin esto un usuario
      // de lector de pantalla recorrería el perfil entero sin escuchar de quién
      // es (mismo criterio que `SettingsUserCard`).
      label: '$nombre. Editar nombre y apellido',
      child: ExcludeSemantics(
        // El Material transparente habilita el ripple sobre el degradado: sin
        // él el efecto se pintaría en el Material del Scaffold, o sea debajo.
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: ConstrainedBox(
              // El nombre y el lápiz son chicos: el área tocable se lleva al
              // mínimo recomendado a mano.
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTapTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        nombre,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(Icons.edit_outlined, size: 16, color: color),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Zona del chip de rol.
///
/// - **Cargando:** se reserva el lugar con una copia invisible del chip, para
///   que el hero no crezca —empujando la tarjeta de cifras y los grupos— cuando
///   el rol llega. La reserva es una instancia del chip real y no una altura
///   fija, así vale a cualquier escala tipográfica.
/// - **Sin rol o con error:** no se pinta nada ni se reserva lugar. Un usuario
///   sin asignaciones no tiene rol que mostrar, y dejarle un hueco permanente
///   sería peor que no mostrar nada.
class _ZonaRol extends StatelessWidget {
  const _ZonaRol({required this.rol, required this.esClaro});

  final AsyncValue<RolEnSistema?> rol;
  final bool esClaro;

  @override
  Widget build(BuildContext context) {
    // El error se evalúa ANTES que la carga y no al revés: en Riverpod 3 un
    // provider asíncrono que falla queda como `AsyncLoading` con `hasError` en
    // `true`, así que preguntar primero por `isLoading` dejaría la reserva
    // puesta para siempre — el hueco eterno que justamente se quiere evitar.
    if (rol.hasError) return const SizedBox.shrink();

    if (rol.isLoading) {
      return ExcludeSemantics(
        child: Visibility(
          key: const Key('rol-chip-placeholder'),
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          // El rótulo más largo de los posibles: define el alto de la reserva.
          child: _RolChip(
            texto: RolEnSistema.responsable.etiqueta,
            esClaro: esClaro,
          ),
        ),
      );
    }

    final valor = rol.value;
    if (valor == null) return const SizedBox.shrink();

    return _RolChip(
      key: const Key('rol-chip'),
      texto: valor.etiqueta,
      esClaro: esClaro,
    );
  }
}

/// Pastilla con el rol del usuario.
class _RolChip extends StatelessWidget {
  const _RolChip({super.key, required this.texto, required this.esClaro});

  final String texto;
  final bool esClaro;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fondo = esClaro
        ? Colors.white.withValues(alpha: 0.2)
        : colors.primaryContainer;
    final textoColor = esClaro
        ? Colors.white.withValues(alpha: 0.9)
        : colors.onPrimaryContainer;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_user_outlined, size: 14, color: textoColor),
            const SizedBox(width: AppSpacing.xs),
            Text(
              texto,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: textoColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Círculo tenue de fondo. Decorativo: no recibe toques ni se anuncia.
class _CirculoDecorativo extends StatelessWidget {
  const _CirculoDecorativo({
    required this.diametro,
    required this.opacidad,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  final double diametro;
  final double opacidad;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Container(
            width: diametro,
            height: diametro,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: opacidad),
            ),
          ),
        ),
      ),
    );
  }
}
