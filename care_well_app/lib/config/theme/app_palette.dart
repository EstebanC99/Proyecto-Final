import 'package:flutter/material.dart';

/// Paleta de tokens de diseño de CareWell, resuelta según el brillo del tema.
///
/// Se expone como [ThemeExtension] para que cada token cambie automáticamente
/// entre claro y oscuro al leerse desde el contexto. Los nombres de token son
/// idénticos en ambas variantes: solo cambia el valor.
///
/// Uso desde un widget: `context.colors.textPrimary`.
///
/// Fuente de verdad de los valores: `00-identidad-visual.md`, secciones 2
/// (claro) y 8 (oscuro).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.primaryHover,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.onSecondary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.outline,
    required this.outlineStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.error,
    required this.errorContainer,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.info,
    required this.infoContainer,
    required this.strengthWeak,
    required this.strengthMedium,
    required this.strengthStrong,
    required this.healthAccent,
    required this.healthContainer,
    required this.habitsAccent,
    required this.habitsContainer,
    required this.moodAccent,
    required this.moodContainer,
    required this.moodScaleVeryBad,
    required this.moodScaleBad,
    required this.moodScaleNeutral,
    required this.moodScaleGood,
    required this.moodScaleVeryGood,
    required this.emergencyRed,
    required this.emergencyRedPressed,
    required this.emergencyContainer,
    required this.onEmergency,
    required this.aiAccent,
    required this.aiContainer,
    required this.moodBlobAlpha,
    required this.scrim,
  });

  // Primarios
  /// Color de marca. Botones primarios, foco activo, links de acción.
  final Color primary;

  /// Estado pressed/hover del primario.
  final Color primaryHover;

  /// Fondos suaves de realce (chips, badges, fondos de íconos).
  final Color primaryContainer;

  /// Texto/íconos sobre [primary].
  final Color onPrimary;

  /// Texto sobre [primaryContainer].
  final Color onPrimaryContainer;

  // Secundarios
  /// Acentos cálidos. No se usa para acciones de peligro (eso es [error]).
  final Color secondary;

  /// Fondos suaves de acento.
  final Color secondaryContainer;

  /// Texto sobre [secondary].
  final Color onSecondary;

  // Neutros
  /// Fondo general de pantalla.
  final Color background;

  /// Tarjetas, campos, hojas/modales.
  final Color surface;

  /// Superficies sutilmente diferenciadas. En oscuro cumple además el rol de elevación tonal.
  final Color surfaceVariant;

  /// Bordes de campos en reposo, divisores.
  final Color outline;

  /// Bordes de mayor contraste cuando se necesita.
  final Color outlineStrong;

  /// Texto principal (titulares, valores).
  final Color textPrimary;

  /// Texto secundario, labels, ayudas.
  final Color textSecondary;

  /// Placeholder, texto deshabilitado.
  final Color textDisabled;

  // Semánticos
  /// Errores de validación, campos inválidos, acciones destructivas.
  final Color error;
  final Color errorContainer;

  /// Confirmaciones, contraseña fuerte, pantalla de éxito.
  final Color success;
  final Color successContainer;

  /// Advertencias, contraseña de fortaleza media.
  final Color warning;
  final Color warningContainer;

  /// Mensajes informativos neutros.
  final Color info;
  final Color infoContainer;

  // Fortaleza de contraseña
  final Color strengthWeak;
  final Color strengthMedium;
  final Color strengthStrong;

  // Mi salud
  /// Acento del módulo Mi salud / Ficha de salud.
  final Color healthAccent;
  final Color healthContainer;

  /// Acento del sub-módulo Hábitos de vida.
  final Color habitsAccent;
  final Color habitsContainer;

  /// Acento del sub-módulo Estados de ánimo (distinto de la escala de 5 tonos).
  final Color moodAccent;
  final Color moodContainer;

  // Escala de estado de ánimo
  final Color moodScaleVeryBad;
  final Color moodScaleBad;
  final Color moodScaleNeutral;
  final Color moodScaleGood;
  final Color moodScaleVeryGood;

  // Emergencia
  /// Acento del módulo Emergencia.
  ///
  /// Deliberadamente más intenso y cálido que [error]: [error] señala una
  /// validación fallida, mientras que este token acompaña una acción de riesgo
  /// que debe leerse como "peligroso" a primera vista. Por eso ambos tokens
  /// dejaron de compartir valor.
  final Color emergencyRed;

  /// Estado presionado del botón de emergencia.
  ///
  /// La dirección del cambio depende del tema y eso es deliberado: en claro
  /// oscurece el relleno, en oscuro lo aclara. Como la tinta ([onEmergency]) es
  /// oscura en el tema oscuro, oscurecer el relleno ahí bajaría el contraste en
  /// vez de dar feedback. Es el mismo criterio de las *state layers* de
  /// Material 3, que en oscuro superponen blanco.
  final Color emergencyRedPressed;

  final Color emergencyContainer;

  /// Texto/íconos sobre [emergencyRed] y [emergencyRedPressed].
  ///
  /// No sirve [onPrimary]: en oscuro [emergencyRed] es un rojo claro, y el
  /// blanco encima queda en 3.03:1. Sigue la regla de la sección 8.8 del spec
  /// de identidad visual: cuando el relleno se aclara, la tinta se oscurece.
  final Color onEmergency;

  // IA / contenido no clínico
  /// Contenido generado por IA (Resumen inteligente).
  final Color aiAccent;
  final Color aiContainer;

  /// Alpha del fondo del blob del selector de ánimo. Sube en oscuro porque
  /// un mismo alpha se percibe con menos presencia sobre fondo oscuro.
  final double moodBlobAlpha;

  /// Velo de fondo de bottom sheets y diálogos: negro al 40% en claro y al 55%
  /// en oscuro (se necesita más opacidad para separar el modal de un fondo
  /// que ya es oscuro).
  final Color scrim;

  /// Paleta del tema claro (sección 2 del spec).
  static const AppPalette light = AppPalette(
    primary: Color(0xFF1A8C82),
    primaryHover: Color(0xFF157469),
    primaryContainer: Color(0xFFC9EDE8),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryContainer: Color(0xFF0A3D38),
    secondary: Color(0xFFF2785C),
    secondaryContainer: Color(0xFFFCE2DA),
    onSecondary: Color(0xFFFFFFFF),
    background: Color(0xFFF6F8F8),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEDF1F1),
    outline: Color(0xFFC5CECE),
    outlineStrong: Color(0xFF9AA5A5),
    textPrimary: Color(0xFF16201F),
    textSecondary: Color(0xFF566060),
    textDisabled: Color(0xFF9AA5A5),
    error: Color(0xFFD14343),
    errorContainer: Color(0xFFFBE3E3),
    success: Color(0xFF2E9E5B),
    successContainer: Color(0xFFD8F0E1),
    warning: Color(0xFFE0A100),
    warningContainer: Color(0xFFFBF0CF),
    info: Color(0xFF2E77C2),
    infoContainer: Color(0xFFDBE9FB),
    strengthWeak: Color(0xFFD14343),
    strengthMedium: Color(0xFFE0A100),
    strengthStrong: Color(0xFF2E9E5B),
    healthAccent: Color(0xFFE11D48),
    healthContainer: Color(0xFFFFE4E6),
    habitsAccent: Color(0xFFEA580C),
    habitsContainer: Color(0xFFFFEDD5),
    moodAccent: Color(0xFF7C3AED),
    moodContainer: Color(0xFFEDE9FE),
    moodScaleVeryBad: Color(0xFFD14343),
    moodScaleBad: Color(0xFFEA580C),
    moodScaleNeutral: Color(0xFFE0A100),
    moodScaleGood: Color(0xFF65A30D),
    moodScaleVeryGood: Color(0xFF2E9E5B),
    emergencyRed: Color(0xFFC0392B),
    emergencyRedPressed: Color(0xFFA93226),
    emergencyContainer: Color(0xFFFEE2E2),
    onEmergency: Color(0xFFFFFFFF),
    aiAccent: Color(0xFF6366F1),
    aiContainer: Color(0xFFE0E7FF),
    moodBlobAlpha: 0.16,
    scrim: Color(0x66000000),
  );

  /// Paleta del tema oscuro (sección 8 del spec).
  static const AppPalette dark = AppPalette(
    primary: Color(0xFF4FBDB0),
    primaryHover: Color(0xFF3FA89C),
    primaryContainer: Color(0xFF1B3B37),
    onPrimary: Color(0xFF08302B),
    onPrimaryContainer: Color(0xFFA9E6DD),
    secondary: Color(0xFFF59A82),
    secondaryContainer: Color(0xFF3D2117),
    onSecondary: Color(0xFF452016),
    background: Color(0xFF0F1917),
    surface: Color(0xFF16211F),
    surfaceVariant: Color(0xFF1E2B29),
    outline: Color(0xFF30403C),
    outlineStrong: Color(0xFF5C7975),
    textPrimary: Color(0xFFEDF3F2),
    textSecondary: Color(0xFF9DB3AF),
    textDisabled: Color(0xFF5C7975),
    error: Color(0xFFE2727A),
    errorContainer: Color(0xFF3B1E20),
    success: Color(0xFF6FCB8E),
    successContainer: Color(0xFF1C3327),
    warning: Color(0xFFF0C05A),
    warningContainer: Color(0xFF3A2E12),
    info: Color(0xFF6FA8E0),
    infoContainer: Color(0xFF1B2C3E),
    strengthWeak: Color(0xFFE2727A),
    strengthMedium: Color(0xFFF0C05A),
    strengthStrong: Color(0xFF6FCB8E),
    healthAccent: Color(0xFFF27C93),
    healthContainer: Color(0xFF3B1622),
    habitsAccent: Color(0xFFF0935F),
    habitsContainer: Color(0xFF3A2414),
    moodAccent: Color(0xFFB69CF0),
    moodContainer: Color(0xFF2A2140),
    moodScaleVeryBad: Color(0xFFE2727A),
    moodScaleBad: Color(0xFFF0935F),
    moodScaleNeutral: Color(0xFFF0C05A),
    moodScaleGood: Color(0xFFC3DE7B),
    moodScaleVeryGood: Color(0xFF6FCB8E),
    emergencyRed: Color(0xFFE17A70),
    emergencyRedPressed: Color(0xFFE7968D),
    emergencyContainer: Color(0xFF3B1E20),
    onEmergency: Color(0xFF2A1012),
    aiAccent: Color(0xFFA5A8F5),
    aiContainer: Color(0xFF26254A),
    moodBlobAlpha: 0.20,
    scrim: Color(0x8C000000),
  );

  @override
  AppPalette copyWith({
    Color? primary,
    Color? primaryHover,
    Color? primaryContainer,
    Color? onPrimary,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? secondaryContainer,
    Color? onSecondary,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? outline,
    Color? outlineStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? error,
    Color? errorContainer,
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? info,
    Color? infoContainer,
    Color? strengthWeak,
    Color? strengthMedium,
    Color? strengthStrong,
    Color? healthAccent,
    Color? healthContainer,
    Color? habitsAccent,
    Color? habitsContainer,
    Color? moodAccent,
    Color? moodContainer,
    Color? moodScaleVeryBad,
    Color? moodScaleBad,
    Color? moodScaleNeutral,
    Color? moodScaleGood,
    Color? moodScaleVeryGood,
    Color? emergencyRed,
    Color? emergencyRedPressed,
    Color? emergencyContainer,
    Color? onEmergency,
    Color? aiAccent,
    Color? aiContainer,
    double? moodBlobAlpha,
    Color? scrim,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimary: onPrimary ?? this.onPrimary,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondary: onSecondary ?? this.onSecondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      outline: outline ?? this.outline,
      outlineStrong: outlineStrong ?? this.outlineStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      strengthWeak: strengthWeak ?? this.strengthWeak,
      strengthMedium: strengthMedium ?? this.strengthMedium,
      strengthStrong: strengthStrong ?? this.strengthStrong,
      healthAccent: healthAccent ?? this.healthAccent,
      healthContainer: healthContainer ?? this.healthContainer,
      habitsAccent: habitsAccent ?? this.habitsAccent,
      habitsContainer: habitsContainer ?? this.habitsContainer,
      moodAccent: moodAccent ?? this.moodAccent,
      moodContainer: moodContainer ?? this.moodContainer,
      moodScaleVeryBad: moodScaleVeryBad ?? this.moodScaleVeryBad,
      moodScaleBad: moodScaleBad ?? this.moodScaleBad,
      moodScaleNeutral: moodScaleNeutral ?? this.moodScaleNeutral,
      moodScaleGood: moodScaleGood ?? this.moodScaleGood,
      moodScaleVeryGood: moodScaleVeryGood ?? this.moodScaleVeryGood,
      emergencyRed: emergencyRed ?? this.emergencyRed,
      emergencyRedPressed: emergencyRedPressed ?? this.emergencyRedPressed,
      emergencyContainer: emergencyContainer ?? this.emergencyContainer,
      onEmergency: onEmergency ?? this.onEmergency,
      aiAccent: aiAccent ?? this.aiAccent,
      aiContainer: aiContainer ?? this.aiContainer,
      moodBlobAlpha: moodBlobAlpha ?? this.moodBlobAlpha,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineStrong: Color.lerp(outlineStrong, other.outlineStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      strengthWeak: Color.lerp(strengthWeak, other.strengthWeak, t)!,
      strengthMedium: Color.lerp(strengthMedium, other.strengthMedium, t)!,
      strengthStrong: Color.lerp(strengthStrong, other.strengthStrong, t)!,
      healthAccent: Color.lerp(healthAccent, other.healthAccent, t)!,
      healthContainer: Color.lerp(healthContainer, other.healthContainer, t)!,
      habitsAccent: Color.lerp(habitsAccent, other.habitsAccent, t)!,
      habitsContainer: Color.lerp(habitsContainer, other.habitsContainer, t)!,
      moodAccent: Color.lerp(moodAccent, other.moodAccent, t)!,
      moodContainer: Color.lerp(moodContainer, other.moodContainer, t)!,
      moodScaleVeryBad: Color.lerp(
        moodScaleVeryBad,
        other.moodScaleVeryBad,
        t,
      )!,
      moodScaleBad: Color.lerp(moodScaleBad, other.moodScaleBad, t)!,
      moodScaleNeutral: Color.lerp(
        moodScaleNeutral,
        other.moodScaleNeutral,
        t,
      )!,
      moodScaleGood: Color.lerp(moodScaleGood, other.moodScaleGood, t)!,
      moodScaleVeryGood: Color.lerp(
        moodScaleVeryGood,
        other.moodScaleVeryGood,
        t,
      )!,
      emergencyRed: Color.lerp(emergencyRed, other.emergencyRed, t)!,
      emergencyRedPressed: Color.lerp(
        emergencyRedPressed,
        other.emergencyRedPressed,
        t,
      )!,
      emergencyContainer: Color.lerp(
        emergencyContainer,
        other.emergencyContainer,
        t,
      )!,
      onEmergency: Color.lerp(onEmergency, other.onEmergency, t)!,
      aiAccent: Color.lerp(aiAccent, other.aiAccent, t)!,
      aiContainer: Color.lerp(aiContainer, other.aiContainer, t)!,
      moodBlobAlpha: moodBlobAlpha + (other.moodBlobAlpha - moodBlobAlpha) * t,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}

/// Acceso corto a la paleta del tema vigente desde cualquier [BuildContext].
///
/// Reemplaza el acceso a constantes estáticas de color: al resolverse contra el
/// tema, el mismo código sirve para claro y oscuro.
extension AppPaletteContext on BuildContext {
  /// Paleta de colores del tema vigente.
  AppPalette get colors =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
