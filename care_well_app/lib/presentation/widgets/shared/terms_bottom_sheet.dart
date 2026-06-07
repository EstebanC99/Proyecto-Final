import 'package:flutter/material.dart';

import '../../../config/constraints/terms_content.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import 'primary_button.dart';
import 'secondary_text_button.dart';

/// Bottom sheet modal con el texto de Términos y Condiciones.
///
/// Usar [TermsBottomSheet.show] para abrirlo. Retorna `true` si el usuario
/// aceptó los T&C, `false` si cerró sin aceptar, y `null` si fue descartado
/// por el sistema.
class TermsBottomSheet extends StatelessWidget {
  const TermsBottomSheet({super.key});

  /// Muestra el bottom sheet de T&C y devuelve si el usuario aceptó.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      builder: (_) => const TermsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Grabber
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
        ),
        // Encabezado
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Términos y Condiciones',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close),
                color: AppColors.textPrimary,
                tooltip: 'Cerrar sin aceptar',
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.outline),
        // Cuerpo scrolleable
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Versión $kTermsVersion',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _Section(
                  title: '1. Aceptación',
                  body:
                      'Al crear una cuenta en CareWell aceptás estos Términos y Condiciones de uso. '
                      'Si no estás de acuerdo con alguna de las condiciones aquí establecidas, '
                      'te pedimos que no uses la aplicación.',
                ),
                _Section(
                  title: '2. Uso de los datos',
                  body:
                      'CareWell centraliza información sensible sobre personas bajo cuidado. '
                      'Los datos que ingresás son de tu exclusiva responsabilidad. '
                      'La aplicación no comparte tu información con terceros sin tu consentimiento explícito, '
                      'salvo en los casos requeridos por la ley.',
                ),
                _Section(
                  title: '3. Privacidad',
                  body:
                      'Nos comprometemos a proteger la privacidad de las personas registradas en el sistema. '
                      'La información médica y personal se almacena de forma segura y cifrada. '
                      'Podés solicitar la eliminación de tus datos en cualquier momento desde la sección Configuración.',
                ),
                _Section(
                  title: '4. Responsabilidades del usuario',
                  body:
                      'El usuario es responsable de mantener sus credenciales seguras y de '
                      'notificar de inmediato cualquier acceso no autorizado. '
                      'El uso de la información de salud es orientativo; nunca reemplaza el '
                      'criterio de un profesional médico.',
                ),
                _Section(
                  title: '5. Limitación de responsabilidad',
                  body:
                      'CareWell se provee "tal como está". No garantizamos disponibilidad '
                      'ininterrumpida ni ausencia de errores. No somos responsables por '
                      'decisiones médicas tomadas en base a la información registrada en la app.',
                ),
                _Section(
                  title: '6. Modificaciones',
                  body:
                      'Podemos actualizar estos Términos periódicamente. Te notificaremos '
                      'ante cambios relevantes. El uso continuado de la app implica la '
                      'aceptación de los términos vigentes.',
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.outline),
        // Acciones fijas
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                label: 'Aceptar y continuar',
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: AppSpacing.sm),
              SecondaryTextButton(
                label: 'Cerrar sin aceptar',
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sección de título + párrafo para el cuerpo del bottom sheet.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
