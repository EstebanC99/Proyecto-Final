import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primarios
  static const Color primary = Color(0xFF1A8C82);
  static const Color primaryHover = Color(0xFF157469);
  static const Color primaryContainer = Color(0xFFC9EDE8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF0A3D38);

  // Secundarios
  static const Color secondary = Color(0xFFF2785C);
  static const Color secondaryContainer = Color(0xFFFCE2DA);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Neutros
  static const Color background = Color(0xFFF6F8F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEDF1F1);
  static const Color outline = Color(0xFFC5CECE);
  static const Color outlineStrong = Color(0xFF9AA5A5);
  static const Color textPrimary = Color(0xFF16201F);
  static const Color textSecondary = Color(0xFF566060);
  static const Color textDisabled = Color(0xFF9AA5A5);

  // Semánticos
  static const Color error = Color(0xFFD14343);
  static const Color errorContainer = Color(0xFFFBE3E3);
  static const Color success = Color(0xFF2E9E5B);
  static const Color successContainer = Color(0xFFD8F0E1);
  static const Color warning = Color(0xFFE0A100);
  static const Color warningContainer = Color(0xFFFBF0CF);
  static const Color info = Color(0xFF2E77C2);
  static const Color infoContainer = Color(0xFFDBE9FB);

  // Fortaleza de contraseña
  static const Color strengthWeak = Color(0xFFD14343);
  static const Color strengthMedium = Color(0xFFE0A100);
  static const Color strengthStrong = Color(0xFF2E9E5B);

  // Mi salud
  static const Color healthAccent = Color(0xFFE11D48);
  static const Color healthContainer = Color(0xFFFFE4E6);
  static const Color habitsAccent = Color(0xFFEA580C);
  static const Color habitsContainer = Color(0xFFFFEDD5);
  static const Color moodAccent = Color(0xFF7C3AED);
  static const Color moodContainer = Color(0xFFEDE9FE);

  // Emergencia
  static const Color emergencyRed = Color(0xFFD14343);
  static const Color emergencyContainer = Color(0xFFFEE2E2);
}
