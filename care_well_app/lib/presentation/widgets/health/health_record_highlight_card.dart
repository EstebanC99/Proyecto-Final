import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Card destacada de acceso a la Ficha de salud, con un resumen de su contenido.
///
/// Es un widget tonto: recibe los datos ya resueltos y los callbacks. Cubre los
/// tres estados de la ficha en el hub: cargando (spinner en el trailing, sin
/// atenuar), sin permiso ([enabled] en `false`: atenuada, con candado y sin
/// tap) y habilitada (chevron y chips de resumen).
class HealthRecordHighlightCard extends StatelessWidget {
  const HealthRecordHighlightCard({
    super.key,
    required this.onTap,
    this.factorSanguineo,
    this.cantidadAlergias = 0,
    this.cantidadEnfermedades = 0,
    this.cantidadAntecedentes = 0,
    this.enabled = true,
    this.loading = false,
    this.datosDisponibles = true,
  });

  final VoidCallback onTap;

  /// Grupo y factor sanguíneo. `null` o vacío si la ficha todavía no se cargó.
  final String? factorSanguineo;

  final int cantidadAlergias;
  final int cantidadEnfermedades;
  final int cantidadAntecedentes;

  /// Cuando es `false` la card se muestra atenuada, con candado y sin tap
  /// (el usuario no tiene permiso para ver la ficha).
  ///
  /// Los chips de resumen se muestran igual: son datos agregados, sin detalle
  /// clínico, y lo que el permiso protege es el acceso a la ficha completa.
  final bool enabled;

  /// Cuando es `true` el estado todavía se está resolviendo: se muestra un
  /// indicador en el trailing, sin atenuar y sin chips. Tiene prioridad sobre
  /// [enabled] para evitar el parpadeo "bloqueada→desbloqueada".
  final bool loading;

  /// Cuando es `false` no se dibuja la fila de chips (la ficha aún no se
  /// resolvió o falló su consulta): la card sigue siendo un acceso válido.
  final bool datosDisponibles;

  @override
  Widget build(BuildContext context) {
    final habilitada = !loading && enabled;
    // Los chips no dependen del permiso: sólo de que el resumen haya llegado.
    final chips = !loading && datosDisponibles ? _chips(context) : const [];

    final card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppSpacing.elev1,
        border: Border(
          left: BorderSide(color: context.colors.healthAccent, width: 4),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: habilitada ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Encabezado(habilitada: habilitada, loading: loading),
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Divider(height: 1, color: context.colors.outline),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(spacing: 8, runSpacing: 8, children: [...chips]),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return MergeSemantics(
      child: Semantics(
        button: habilitada,
        label: _semanticsLabel(),
        child: habilitada || loading
            ? card
            : Opacity(opacity: 0.5, child: card),
      ),
    );
  }

  /// Chips de resumen de la ficha. Los recuentos en cero no se muestran: un
  /// "0 alergias" es ruido, no información.
  List<Widget> _chips(BuildContext context) {
    return [
      // Sin factor cargado el chip es sólo el copy de vacío: el prefijo
      // "Grupo " únicamente acompaña a un valor real.
      if (_tieneFactor)
        _FichaChip(prefijo: 'Grupo ', valor: factorSanguineo!)
      else
        const _FichaChip(valor: null, textoAlternativo: 'Sin grupo cargado'),
      if (cantidadAlergias > 0)
        _FichaChip(
          valor: _pluralizar(cantidadAlergias, 'alergia', 'alergias'),
          destacado: true,
        ),
      if (cantidadEnfermedades > 0)
        _FichaChip(
          valor: _pluralizar(
            cantidadEnfermedades,
            'enfermedad',
            'enfermedades',
          ),
        ),
      if (cantidadAntecedentes > 0)
        _FichaChip(
          valor: _pluralizar(
            cantidadAntecedentes,
            'antecedente',
            'antecedentes',
          ),
        ),
    ];
  }

  bool get _tieneFactor =>
      factorSanguineo != null && factorSanguineo!.trim().isNotEmpty;

  static String _pluralizar(int cantidad, String singular, String plural) =>
      '$cantidad ${cantidad == 1 ? singular : plural}';

  String _semanticsLabel() {
    if (loading) return 'Ficha de salud, cargando';
    if (!datosDisponibles) {
      return enabled
          ? 'Ficha de salud'
          : 'Ficha de salud, sin permiso para verla';
    }

    final partes = <String>[
      if (!enabled) 'sin permiso para ver el detalle',
      _tieneFactor ? 'grupo $factorSanguineo' : 'sin grupo cargado',
      if (cantidadAlergias > 0)
        _pluralizar(cantidadAlergias, 'alergia', 'alergias'),
      if (cantidadEnfermedades > 0)
        _pluralizar(cantidadEnfermedades, 'enfermedad', 'enfermedades'),
      if (cantidadAntecedentes > 0)
        _pluralizar(cantidadAntecedentes, 'antecedente', 'antecedentes'),
    ];
    return 'Ficha de salud, ${partes.join(', ')}';
  }
}

/// Fila superior: ícono, título, bajada y trailing según el estado.
class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.habilitada, required this.loading});

  final bool habilitada;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.colors.healthContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(
            Icons.medical_services_outlined,
            size: 22,
            color: context.colors.healthAccent,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ficha de salud',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Datos clínicos para una emergencia',
                style: TextStyle(
                  fontSize: 12.5,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (loading)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.colors.healthAccent,
              ),
            ),
          )
        else
          Icon(
            habilitada ? Icons.chevron_right : Icons.lock_outline,
            size: 20,
            color: context.colors.textDisabled,
          ),
      ],
    );
  }
}

/// Chip de resumen de la ficha.
class _FichaChip extends StatelessWidget {
  const _FichaChip({
    required this.valor,
    this.prefijo,
    this.textoAlternativo,
    this.destacado = false,
  });

  /// Valor a destacar dentro del chip. Si es `null` se muestra
  /// [textoAlternativo] como texto plano.
  final String? valor;

  /// Texto neutro que antecede al valor (por ejemplo "Grupo ").
  final String? prefijo;

  /// Texto de reemplazo cuando no hay [valor].
  final String? textoAlternativo;

  /// Chip con la tinta de salud, para lo que conviene mirar primero.
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final fondo = destacado
        ? context.colors.healthContainer
        : context.colors.surfaceVariant;
    final tinta = destacado
        ? context.colors.healthAccent
        : context.colors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            if (prefijo != null) TextSpan(text: prefijo),
            if (valor != null)
              TextSpan(
                text: valor,
                style: const TextStyle(fontWeight: FontWeight.w700),
              )
            else
              TextSpan(text: textoAlternativo ?? ''),
          ],
        ),
        style: TextStyle(fontSize: 12, color: tinta),
      ),
    );
  }
}
