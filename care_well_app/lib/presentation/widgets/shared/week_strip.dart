import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Tira semanal: encabezado de mes con flechas ‹ › y los siete días de la
/// semana con un indicador de cuántos eventos tiene cada uno.
///
/// Se puede cambiar de semana con las flechas o deslizando horizontalmente
/// sobre la tira: hacia la derecha va a la semana anterior y hacia la
/// izquierda a la siguiente, siguiendo la convención de los calendarios (el
/// contenido acompaña al dedo).
///
/// El día de hoy se resalta con el color de acento en el texto; el día
/// seleccionado, con relleno sólido. Es completamente presentacional: la
/// semana y el día activos los mantiene la pantalla contenedora. La comparten
/// la agenda y los eventos de salud.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.lunesSemana,
    required this.diaSeleccionado,
    required this.onSelectDia,
    required this.onPreviousWeek,
    required this.onNextWeek,
    this.cantidadPorDia = const {},
    this.hoy,
    this.accentColor,
    this.maxDiaSeleccionable,
  });

  /// Lunes (00:00) de la semana que se muestra.
  final DateTime lunesSemana;

  /// Día actualmente seleccionado.
  final DateTime diaSeleccionado;

  /// Cantidad de eventos por día (fechas truncadas a año-mes-día).
  final Map<DateTime, int> cantidadPorDia;

  final ValueChanged<DateTime> onSelectDia;

  /// Navegación a la semana anterior. Si es `null`, la flecha se muestra
  /// deshabilitada y el swipe hacia esa dirección no hace nada.
  final VoidCallback? onPreviousWeek;

  /// Navegación a la semana siguiente. Si es `null`, la flecha se muestra
  /// deshabilitada y el swipe hacia esa dirección no hace nada (p. ej. para
  /// impedir avanzar a semanas futuras).
  final VoidCallback? onNextWeek;

  /// Fecha considerada "hoy". Inyectable para tests; por defecto, la del reloj.
  final DateTime? hoy;

  /// Color de acento del día de hoy y del relleno del día seleccionado.
  /// Por defecto, el color primario de la app.
  final Color? accentColor;

  /// Último día seleccionable (inclusive). Los días posteriores se muestran
  /// atenuados y no responden al toque. Si es `null`, no hay restricción.
  final DateTime? maxDiaSeleccionable;

  /// Cantidad máxima de puntitos que se dibujan bajo un día.
  static const int _maxPips = 3;

  /// Velocidad horizontal mínima (px/s) para que un desplazamiento se
  /// interprete como cambio de semana. Evita que un roce al tocar un día
  /// dispare la navegación.
  static const double _velocidadMinimaSwipe = 200;

  /// Resuelve el gesto horizontal: velocidad positiva (dedo hacia la derecha)
  /// trae la semana anterior; negativa, la siguiente.
  void _resolverSwipe(DragEndDetails details) {
    final velocidad = details.primaryVelocity;
    if (velocidad == null || velocidad.abs() < _velocidadMinimaSwipe) return;
    if (velocidad > 0) {
      onPreviousWeek?.call();
    } else {
      onNextWeek?.call();
    }
  }

  static const _nombresMes = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  static const _nombresDiaCorto = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá', 'Do'];

  /// Etiqueta del mes de la semana visible.
  ///
  /// Cuando la semana cruza dos meses se muestran ambos ("Ago · Sep 2026")
  /// para que el encabezado no mienta sobre los días que se están viendo.
  String _etiquetaMes() {
    final domingo = lunesSemana.add(const Duration(days: 6));
    final mesInicio = _nombresMes[lunesSemana.month - 1];
    if (lunesSemana.month == domingo.month) {
      return '$mesInicio ${lunesSemana.year}';
    }
    final mesFin = _nombresMes[domingo.month - 1];
    final inicioCorto = mesInicio.substring(0, 3);
    final finCorto = mesFin.substring(0, 3);
    return lunesSemana.year == domingo.year
        ? '$inicioCorto · $finCorto ${domingo.year}'
        : '$inicioCorto ${lunesSemana.year} · $finCorto ${domingo.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ahora = hoy ?? DateTime.now();
    final hoyTruncado = DateTime(ahora.year, ahora.month, ahora.day);
    final seleccionado = DateTime(
      diaSeleccionado.year,
      diaSeleccionado.month,
      diaSeleccionado.day,
    );
    final acento = accentColor ?? context.colors.primary;
    final maximo = maxDiaSeleccionable == null
        ? null
        : DateTime(
            maxDiaSeleccionable!.year,
            maxDiaSeleccionable!.month,
            maxDiaSeleccionable!.day,
          );
    final dias = [
      for (var i = 0; i < 7; i++) lunesSemana.add(Duration(days: i)),
    ];

    return GestureDetector(
      // Sumado a las flechas, no en su reemplazo: el swipe es el gesto
      // esperado en un calendario, pero las flechas siguen siendo el camino
      // accesible (y el único con tooltip).
      onHorizontalDragEnd: _resolverSwipe,
      // opaque: el gesto también debe tomarse sobre los espacios vacíos entre
      // los días.
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(
            top: BorderSide(color: context.colors.outline, width: 0.5),
            bottom: BorderSide(color: context.colors.outline, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.md,
        ),
        child: Column(
          children: [
            // Mes + navegación de semana.
            Row(
              children: [
                _ArrowButton(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Semana anterior',
                  acento: acento,
                  onTap: onPreviousWeek,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _etiquetaMes(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ),
                _ArrowButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'Semana siguiente',
                  acento: acento,
                  onTap: onNextWeek,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Los siete días.
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: _DayCell(
                      fecha: dias[i],
                      etiquetaDia: _nombresDiaCorto[i],
                      esHoy: dias[i] == hoyTruncado,
                      esSeleccionado: dias[i] == seleccionado,
                      habilitado: maximo == null || !dias[i].isAfter(maximo),
                      cantidad: cantidadPorDia[dias[i]] ?? 0,
                      maxPips: _maxPips,
                      acento: acento,
                      onTap: onSelectDia,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Partes internas ─────────────────────────────────────────────────────────

/// Celda de un día dentro de la tira semanal.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.fecha,
    required this.etiquetaDia,
    required this.esHoy,
    required this.esSeleccionado,
    required this.habilitado,
    required this.cantidad,
    required this.maxPips,
    required this.acento,
    required this.onTap,
  });

  final DateTime fecha;
  final String etiquetaDia;
  final bool esHoy;
  final bool esSeleccionado;

  /// `false` para los días que quedan fuera del rango seleccionable: se
  /// muestran atenuados y no responden al toque.
  final bool habilitado;
  final int cantidad;
  final int maxPips;
  final Color acento;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final colorTexto = esSeleccionado
        ? context.colors.onPrimary
        : !habilitado
        ? context.colors.textDisabled
        : esHoy
        ? acento
        : context.colors.textPrimary;
    final colorEtiqueta = esSeleccionado
        ? context.colors.onPrimary
        : !habilitado
        ? context.colors.textDisabled
        : esHoy
        ? acento
        : context.colors.textSecondary;

    return Semantics(
      selected: esSeleccionado,
      button: habilitado,
      enabled: habilitado,
      label: '${fecha.day}, $cantidad eventos',
      child: InkWell(
        onTap: habilitado ? () => onTap(fecha) : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: esSeleccionado ? acento : null,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                etiquetaDia.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: esSeleccionado
                      ? FontWeight.w700
                      : FontWeight.w500,
                  letterSpacing: 0.4,
                  color: colorEtiqueta,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${fecha.day}',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: esSeleccionado || esHoy
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: colorTexto,
                ),
              ),
              const SizedBox(height: 5),
              // Puntitos de cantidad de eventos. La fila ocupa lugar siempre,
              // así los días sin eventos no cambian la altura de la tira.
              SizedBox(
                height: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < cantidad.clamp(0, maxPips); i++)
                      Padding(
                        padding: EdgeInsets.only(left: i == 0 ? 0 : 3),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: esSeleccionado
                                ? context.colors.onPrimary.withValues(
                                    alpha: 0.9,
                                  )
                                : context.colors.outlineStrong,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón de flecha con área táctil mínima de 48 dp.
///
/// Con [onTap] en `null` se muestra atenuado y no responde al toque.
class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.acento,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color acento;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final habilitado = onTap != null;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: SizedBox(
          width: AppSpacing.minTapTarget,
          height: AppSpacing.minTapTarget,
          child: Icon(
            icon,
            size: 28,
            color: habilitado ? acento : context.colors.textDisabled,
          ),
        ),
      ),
    );
  }
}
