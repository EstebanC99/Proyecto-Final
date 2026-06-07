import 'package:flutter/material.dart';

abstract final class AppSpacing {
  // Escala base-4
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Radios de esquinas
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 28;
  static const double radiusFull = 999;

  // Elevaciones (sombras)
  static const List<BoxShadow> elev0 = [];

  static const List<BoxShadow> elev1 = [
    BoxShadow(color: Color(0x0F16201F), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> elev2 = [
    BoxShadow(color: Color(0x1F16201F), blurRadius: 24, offset: Offset(0, 8)),
  ];

  // Alturas de componentes
  static const double buttonHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double inputHeight = 56.0;
  static const double minTapTarget = 48.0;
}
