import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';

/// Anillo de progreso de los hábitos del día (US 9.16).
///
/// Dibuja el avance con un [CustomPainter] y lo anima desde 0 al valor final.
/// En el centro muestra "completados/total". Es puramente presentacional: no
/// recalcula totales, los recibe ya resueltos por la entidad del resumen.
class HabitsProgressRing extends StatelessWidget {
  const HabitsProgressRing({
    super.key,
    required this.completados,
    required this.total,
    required this.progreso,
    this.size = 82,
  });

  /// Hábitos ya registrados como realizados.
  final int completados;

  /// Hábitos previstos para el día.
  final int total;

  /// Avance entre 0.0 y 1.0 (la entidad ya evita la división por cero).
  final double progreso;

  /// Lado del cuadrado que ocupa el anillo con la escala tipográfica al 100%.
  final double size;

  static const double _grosor = 8;

  /// Tope de crecimiento del anillo: más allá le robaría todo el ancho al
  /// comentario que va al lado.
  static const double _escalaMaxima = 1.6;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sinAnimacion = MediaQuery.disableAnimationsOf(context);
    final valor = progreso.clamp(0.0, 1.0);
    // El anillo acompaña la escala tipográfica del sistema (hasta el tope) y el
    // texto del centro se achica si aun así no entra.
    final escala = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, _escalaMaxima);
    final lado = size * escala;

    return Semantics(
      label: '$completados de $total hábitos completados',
      excludeSemantics: true,
      child: SizedBox(
        width: lado,
        height: lado,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: valor),
              duration: Duration(milliseconds: sinAnimacion ? 0 : 900),
              curve: Curves.easeOutCubic,
              builder: (context, animado, _) => CustomPaint(
                size: Size.square(lado),
                painter: _RingPainter(
                  progreso: animado,
                  trackColor: colors.surfaceVariant,
                  progressColor: colors.habitsAccent,
                  grosor: _grosor,
                ),
              ),
            ),
            Padding(
              // Deja libre el trazo del anillo para que el texto no lo pise.
              padding: const EdgeInsets.all(_grosor + 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$completados/$total',
                      style: TextStyle(
                        fontSize: 22,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        color: colors.habitsAccent,
                      ),
                    ),
                    Text(
                      'completos',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pinta la pista completa y, encima, el arco de avance con extremos
/// redondeados, arrancando arriba (-90°) y en sentido horario.
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progreso,
    required this.trackColor,
    required this.progressColor,
    required this.grosor,
  });

  final double progreso;
  final Color trackColor;
  final Color progressColor;
  final double grosor;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final radio = (math.min(size.width, size.height) - grosor) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..color = trackColor;
    canvas.drawCircle(centro, radio, track);

    if (progreso <= 0) return;

    final arco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round
      ..color = progressColor;
    canvas.drawArc(
      Rect.fromCircle(center: centro, radius: radio),
      -math.pi / 2,
      2 * math.pi * progreso,
      false,
      arco,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progreso != progreso ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.grosor != grosor;
}
