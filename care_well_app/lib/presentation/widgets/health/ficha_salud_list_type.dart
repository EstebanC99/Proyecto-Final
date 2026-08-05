import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';

/// Tipos de lista de la Ficha de salud. Un único descriptor centraliza el
/// acento visual, ícono y textos de cada tipo, para reutilizarlos en la
/// sección, la card de ítem y el bottom sheet de alta/edición.
enum FichaListType { antecedentes, alergias, enfermedades }

extension FichaListTypeX on FichaListType {
  /// Color de acento (ícono, borde de card, botón "+ Agregar").
  Color accent(BuildContext context) => switch (this) {
    FichaListType.antecedentes => context.colors.healthAccent,
    FichaListType.alergias => context.colors.warning,
    FichaListType.enfermedades => context.colors.info,
  };

  /// Color de contenedor tenue (fondo del ícono en estado vacío).
  Color container(BuildContext context) => switch (this) {
    FichaListType.antecedentes => context.colors.healthContainer,
    FichaListType.alergias => context.colors.warningContainer,
    FichaListType.enfermedades => context.colors.infoContainer,
  };

  IconData get icon => switch (this) {
    FichaListType.antecedentes => Icons.history,
    FichaListType.alergias => Icons.healing,
    FichaListType.enfermedades => Icons.local_hospital,
  };

  /// Título de la sección (plural).
  String get sectionTitle => switch (this) {
    FichaListType.antecedentes => 'Antecedentes',
    FichaListType.alergias => 'Alergias',
    FichaListType.enfermedades => 'Enfermedades',
  };

  /// Nombre singular en minúscula (para títulos del sheet y snackbars).
  String get singular => switch (this) {
    FichaListType.antecedentes => 'antecedente',
    FichaListType.alergias => 'alergia',
    FichaListType.enfermedades => 'enfermedad',
  };

  /// Texto del estado vacío.
  String get emptyText => switch (this) {
    FichaListType.antecedentes => 'Todavía no registraste antecedentes.',
    FichaListType.alergias => 'Todavía no registraste alergias.',
    FichaListType.enfermedades => 'Todavía no registraste enfermedades.',
  };
}
