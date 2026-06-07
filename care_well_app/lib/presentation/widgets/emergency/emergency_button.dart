import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

/// Botón circular grande de emergencia con anillos pulsantes.
///
/// El objetivo táctil incluye los anillos (160dp total).
/// Muestra ícono [Icons.error_outline] con la etiqueta "EMERGENCIA".
class EmergencyButton extends StatefulWidget {
  const EmergencyButton({super.key, required this.onTap, this.enabled = true});

  final VoidCallback onTap;

  /// Si es `false`, el botón aparece con opacidad reducida y no responde a toques.
  final bool enabled;

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.4,
      child: Semantics(
        label: 'Activar emergencia. Abre diálogo de confirmación.',
        button: true,
        enabled: widget.enabled,
        child: GestureDetector(
          onTapDown: widget.enabled
              ? (_) => setState(() => _pressed = true)
              : null,
          onTapUp: widget.enabled
              ? (_) {
                  setState(() => _pressed = false);
                  widget.onTap();
                }
              : null,
          onTapCancel: widget.enabled
              ? () => setState(() => _pressed = false)
              : null,
          child: SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Anillo exterior pulsante
                Pulse(
                  infinite: true,
                  duration: const Duration(milliseconds: 2000),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emergencyRed.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                // Anillo interior estático
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.emergencyRed.withValues(alpha: 0.15),
                  ),
                ),
                // Botón central
                AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pressed
                        ? const Color(0xFFB02F2F)
                        : AppColors.emergencyRed,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emergencyRed.withValues(
                          alpha: _pressed ? 0.3 : 0.4,
                        ),
                        blurRadius: _pressed ? 8 : 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.white),
                      SizedBox(height: 2),
                      Text(
                        'EMERGENCIA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
