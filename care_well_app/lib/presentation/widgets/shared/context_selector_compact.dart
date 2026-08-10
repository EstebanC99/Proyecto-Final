import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import 'persona_avatar.dart';

/// Datos mínimos de una persona para pintar un mini-avatar apilado.
typedef PersonaMini = ({int id, String nombre});

/// Banner compacto de contexto: variante visual del selector de persona usada
/// en Home y Agenda.
///
/// Se resuelve como una fila sin recuadro (no compite con el hero ni con la
/// tira de semana que van debajo): avatar con anillo de marca, rótulo de
/// sección, nombre con badge de rol y, a la derecha, los mini-avatares de las
/// otras personas disponibles como pista de que el contexto se puede cambiar.
///
/// Es puramente presentacional: la lógica de datos y la apertura del selector
/// viven en `ContextSelector`.
class ContextCompactBanner extends StatelessWidget {
  const ContextCompactBanner({
    super.key,
    required this.personaId,
    required this.nombreCompleto,
    required this.eyebrow,
    required this.interactivo,
    this.rolLabel,
    this.otrasPersonas = const [],
  });

  /// Id de la persona de contexto, para resolver su foto de perfil.
  final int personaId;

  final String nombreCompleto;

  /// Rótulo superior en versales ("Estás viendo", "Calendario", ...).
  final String eyebrow;

  /// Cuando `true` muestra el chevron y los mini-avatares (hay más de una
  /// persona seleccionable).
  final bool interactivo;

  /// Badge de rol junto al nombre ("YO", "Responsable", "Cuidador/a").
  final String? rolLabel;

  /// Otras personas seleccionables. Se muestran hasta 3 mini-avatares y, si hay
  /// más, un contador "+N".
  final List<PersonaMini> otrasPersonas;

  /// Cantidad máxima de mini-avatares antes de agrupar en el contador.
  static const int _maxMiniAvatares = 3;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Avatar con anillo de marca.
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.primary, width: 2),
            ),
            padding: const EdgeInsets.all(2),
            child: PersonaAvatar(
              personaId: personaId,
              nombre: nombreCompleto,
              size: 40,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Rótulo + nombre + badge de rol.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    height: 1.2,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        nombreCompleto,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          height: 1.2,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                    if (rolLabel != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _RolBadge(label: rolLabel!),
                    ],
                    if (interactivo) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.expand_more,
                        size: 18,
                        color: context.colors.primary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Mini-avatares apilados de las otras personas disponibles.
          if (interactivo && otrasPersonas.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            _MiniAvatares(personas: otrasPersonas, max: _maxMiniAvatares),
          ],
        ],
      ),
    );
  }
}

// ─── Partes internas ─────────────────────────────────────────────────────────

/// Badge pill del rol de la persona de contexto.
class _RolBadge extends StatelessWidget {
  const _RolBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: context.colors.onPrimaryContainer,
        ),
      ),
    );
  }
}

/// Pila de mini-avatares superpuestos, con contador "+N" si sobran personas.
class _MiniAvatares extends StatelessWidget {
  const _MiniAvatares({required this.personas, required this.max});

  final List<PersonaMini> personas;
  final int max;

  /// Diámetro del avatar, sin contar el anillo.
  static const double _size = 28;

  /// Grosor del anillo que separa un avatar del anterior.
  static const double _ring = 2;

  /// Superposición entre avatares consecutivos.
  static const double _overlap = 9;

  static const double _itemSize = _size + _ring * 2;
  static const double _step = _itemSize - _overlap;

  @override
  Widget build(BuildContext context) {
    final visibles = personas.take(max).toList();
    final restantes = personas.length - visibles.length;

    final items = <Widget>[
      for (final p in visibles)
        _MiniAvatarRing(
          ring: _ring,
          child: PersonaAvatar(personaId: p.id, nombre: p.nombre, size: _size),
        ),
      if (restantes > 0)
        _MiniAvatarRing(
          ring: _ring,
          child: Container(
            width: _size,
            height: _size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Text(
              '+$restantes',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ),
    ];

    // Se apilan con Stack (y no con paddings negativos, que Flutter no admite).
    return SizedBox(
      width: _itemSize + (items.length - 1) * _step,
      height: _itemSize,
      child: Stack(
        children: [
          for (var i = 0; i < items.length; i++)
            Positioned(left: i * _step, child: items[i]),
        ],
      ),
    );
  }
}

/// Anillo del color de la superficie que separa un mini-avatar del anterior.
class _MiniAvatarRing extends StatelessWidget {
  const _MiniAvatarRing({required this.child, required this.ring});

  final Widget child;
  final double ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.surface, width: ring),
      ),
      child: child,
    );
  }
}
