import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Opción de la grilla de tipos, ya resuelta visualmente.
///
/// [TypeTileGrid] no conoce el dominio: las pantallas traducen el catálogo
/// (tipos de hábito, de evento de salud, de evento de agenda) a esta forma
/// usando sus propios helpers de tema (`TipoHabitoTheme`, `TipoEventoTheme`).
@immutable
class TypeTileOption {
  const TypeTileOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.accent,
    required this.container,
  });

  /// Id de catálogo del tipo. Es lo que emite [TypeTileGrid.onChanged].
  final int id;

  /// Texto visible del tipo.
  final String label;

  /// Ícono representativo del tipo.
  final IconData icon;

  /// Color de acento: ícono, borde y texto cuando la opción está elegida.
  final Color accent;

  /// Color de fondo suave de la tarjeta cuando la opción está elegida.
  final Color container;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeTileOption &&
          other.id == id &&
          other.label == label &&
          other.icon == icon &&
          other.accent == accent &&
          other.container == container;

  @override
  int get hashCode => Object.hash(id, label, icon, accent, container);
}

/// Grilla de selección de tipo en dos columnas.
///
/// Reemplaza a los dropdowns de tipo de los formularios: muestra todas las
/// opciones a la vez, con ícono y color propios, para que elegir sea un solo
/// toque. Cuando el catálogo supera [maxVisible] opciones se muestran
/// `maxVisible - 1` y un tile "Ver más" que despliega el resto.
///
/// El orden de [options] se respeta tal cual llega (las pantallas lo definen
/// por id de catálogo); el widget no ordena ni filtra.
class TypeTileGrid extends StatefulWidget {
  const TypeTileGrid({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    this.enabled = true,
    this.maxVisible = 6,
  }) : assert(maxVisible >= 2, 'La grilla necesita al menos dos columnas');

  /// Opciones a mostrar, en el orden en que se dibujan.
  final List<TypeTileOption> options;

  /// Id de la opción elegida; nulo si todavía no se eligió ninguna.
  final int? selectedId;

  /// Se dispara con el id de la opción tocada.
  final ValueChanged<int> onChanged;

  /// Si es `false`, la grilla se ve atenuada y no responde a los toques
  /// (formulario guardando o en modo lectura).
  final bool enabled;

  /// Cantidad máxima de tiles visibles con la grilla colapsada, contando el
  /// tile "Ver más".
  final int maxVisible;

  @override
  State<TypeTileGrid> createState() => _TypeTileGridState();
}

class _TypeTileGridState extends State<TypeTileGrid> {
  /// Separación entre tiles, horizontal y vertical.
  static const _gap = AppSpacing.sm;

  /// Atenuación de la grilla deshabilitada.
  static const _disabledOpacity = 0.5;

  late bool _expandido;

  @override
  void initState() {
    super.initState();
    _expandido = _seleccionOculta;
  }

  @override
  void didUpdateWidget(covariant TypeTileGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Al editar, la selección puede llegar después del primer build (el
    // catálogo se resuelve async): si cae en la parte oculta hay que abrir.
    final cambio =
        oldWidget.selectedId != widget.selectedId ||
        oldWidget.options != widget.options ||
        oldWidget.maxVisible != widget.maxVisible;
    if (cambio && !_expandido && _seleccionOculta) {
      _expandido = true;
    }
  }

  /// Hay más opciones que las que entran con la grilla colapsada.
  bool get _hayOcultas => widget.options.length > widget.maxVisible;

  /// Cantidad de opciones reales visibles con la grilla colapsada.
  int get _visiblesColapsada =>
      _hayOcultas ? widget.maxVisible - 1 : widget.options.length;

  /// La opción elegida quedaría escondida detrás de "Ver más".
  bool get _seleccionOculta {
    if (!_hayOcultas || widget.selectedId == null) return false;
    final indice = widget.options.indexWhere((o) => o.id == widget.selectedId);
    return indice >= _visiblesColapsada;
  }

  @override
  Widget build(BuildContext context) {
    final mostrarTodas = !_hayOcultas || _expandido;
    final visibles = mostrarTodas
        ? widget.options
        : widget.options.take(_visiblesColapsada);

    final grilla = LayoutBuilder(
      builder: (context, constraints) {
        final anchoTile = (constraints.maxWidth - _gap) / 2;

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: Wrap(
            spacing: _gap,
            runSpacing: _gap,
            children: [
              for (final option in visibles)
                SizedBox(
                  width: anchoTile,
                  child: _TypeTile(
                    label: option.label,
                    icon: option.icon,
                    accent: option.accent,
                    container: option.container,
                    selected: option.id == widget.selectedId,
                    onTap: widget.enabled
                        ? () => widget.onChanged(option.id)
                        : null,
                  ),
                ),
              if (_hayOcultas)
                SizedBox(
                  width: anchoTile,
                  child: _TypeTile(
                    label: _expandido ? 'Ver menos' : 'Ver más',
                    icon: _expandido ? Icons.expand_less : Icons.more_horiz,
                    accent: context.colors.primary,
                    container: context.colors.primaryContainer,
                    selected: false,
                    onTap: widget.enabled
                        ? () => setState(() => _expandido = !_expandido)
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (widget.enabled) return grilla;

    return Opacity(opacity: _disabledOpacity, child: grilla);
  }
}

/// Tarjeta individual de la grilla: cuadradito de ícono + rótulo.
class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.label,
    required this.icon,
    required this.accent,
    required this.container,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final Color container;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTapTarget,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: selected ? container : context.colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: selected ? accent : context.colors.outline,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selected
                        ? context.colors.surface
                        : context.colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 18, color: accent),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? accent : context.colors.textPrimary,
                    ),
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
