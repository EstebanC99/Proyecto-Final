import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mixin que encapsula el scroll automático inicial a un "día objetivo" dentro
/// de listas mensuales agrupadas por día (Agenda y Eventos de salud).
///
/// Comparte la lógica repetida de: calcular el día objetivo del mes actual,
/// desplazar la lista una única vez por carga de datos y reiniciar ese estado
/// cuando los datos cambian (nuevo mes, nueva persona, refresco).
///
/// El estado ([_yaHizoScrollInicial]) es propio de cada `State`, por lo que dos
/// pantallas distintas no se interfieren.
mixin InitialDayScrollMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  /// Clave asignada al grupo del día objetivo para poder desplazarse a él.
  final GlobalKey diaObjetivoKey = GlobalKey();

  /// Evita repetir el scroll inicial en cada rebuild (p. ej. al expandir o
  /// colapsar un grupo). Se reinicia con [reiniciarScrollInicial].
  bool _yaHizoScrollInicial = false;

  /// Habilita nuevamente el scroll inicial. Debe llamarse cada vez que se
  /// recargan los datos (entrar, cambiar de mes o de persona, refrescar).
  void reiniciarScrollInicial() => _yaHizoScrollInicial = false;

  /// Determina a qué día debe desplazarse la lista al cargar el mes actual.
  ///
  /// Solo aplica cuando [mes] es el mes en curso. Prioriza el grupo de "hoy";
  /// si hoy no tiene eventos, va al próximo evento (primer día posterior a hoy)
  /// y, si no hay ninguno posterior, al último día anterior. Devuelve `null`
  /// cuando no corresponde hacer scroll (otro mes o lista vacía).
  DateTime? calcularDiaObjetivo(List<DateTime> dias, DateTime mes) {
    final now = DateTime.now();
    final esMesActual = mes.year == now.year && mes.month == now.month;
    if (!esMesActual || dias.isEmpty) return null;

    final today = DateTime(now.year, now.month, now.day);
    for (final d in dias) {
      if (d == today) return d;
    }
    for (final d in dias) {
      if (d.isAfter(today)) return d;
    }
    return dias.last;
  }

  /// Desplaza la lista al [diaObjetivo] una única vez por carga de datos,
  /// alineándolo arriba del viewport. No hace nada si ya se desplazó o si el
  /// día objetivo es `null`.
  void scrollAlDiaObjetivoUnaVez(DateTime? diaObjetivo) {
    if (_yaHizoScrollInicial || diaObjetivo == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = diaObjetivoKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _yaHizoScrollInicial = true;
    });
  }
}
