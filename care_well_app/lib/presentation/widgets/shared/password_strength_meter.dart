import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Nivel de fortaleza de una contraseña.
enum PasswordStrength {
  /// Menos de 8 caracteres.
  weak,

  /// 8 o más caracteres sin mayúscula y sin número.
  medium,

  /// 8 o más caracteres con al menos una mayúscula y un número.
  strong,
}

/// Calcula el nivel de fortaleza de [password].
PasswordStrength calcularFortaleza(String password) {
  if (password.length < 8) return PasswordStrength.weak;
  final tieneMayuscula = password.contains(RegExp(r'[A-Z]'));
  final tieneNumero = password.contains(RegExp(r'[0-9]'));
  if (tieneMayuscula && tieneNumero) return PasswordStrength.strong;
  return PasswordStrength.medium;
}

/// Medidor visual de fortaleza de contraseña.
///
/// Muestra 3 segmentos coloreados según [password]:
/// - Rojo (débil): < 8 caracteres.
/// - Naranja (media): 8+ sin mayúscula o sin número.
/// - Verde (fuerte): 8+ con mayúscula y número.
///
/// El helper "Mínimo 8 caracteres" siempre es visible.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strength = password.isEmpty ? null : calcularFortaleza(password);

    Color segmentColor(int segmentIndex) {
      if (strength == null) {
        return theme.colorScheme.surfaceContainerHighest;
      }
      final activeSegments = switch (strength) {
        PasswordStrength.weak => 1,
        PasswordStrength.medium => 2,
        PasswordStrength.strong => 3,
      };
      if (segmentIndex >= activeSegments) {
        return theme.colorScheme.surfaceContainerHighest;
      }
      return switch (strength) {
        PasswordStrength.weak => AppColors.strengthWeak,
        PasswordStrength.medium => AppColors.strengthMedium,
        PasswordStrength.strong => AppColors.strengthStrong,
      };
    }

    String labelText() {
      return switch (strength) {
        null => 'Mínimo 8 caracteres',
        PasswordStrength.weak => 'Débil',
        PasswordStrength.medium => 'Media',
        PasswordStrength.strong => 'Fuerte',
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(3, (index) {
            final isLast = index == 2;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: isLast ? 0 : AppSpacing.xs),
                decoration: BoxDecoration(
                  color: segmentColor(index),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          labelText(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
