/// Rótulo relativo de la última vez que pasó algo ("hoy", "ayer",
/// "hace 3 días", "hace 2 semanas"...).
///
/// La comparación se hace por día calendario en hora local: dos momentos del
/// mismo día son siempre "hoy", sin importar la hora. [ahora] permite fijar el
/// presente en los tests; por defecto es `DateTime.now()`.
///
/// Función pura: no depende de `intl` ni del árbol de widgets.
String textoRelativoDesde(DateTime fecha, {DateTime? ahora}) {
  final hoy = _soloFecha(ahora ?? DateTime.now());
  final dia = _soloFecha(fecha);
  return textoRelativoEnDias(hoy.difference(dia).inDays);
}

/// Rótulo relativo a partir de una cantidad de [dias] ya calculada.
///
/// Lo usa el resumen de salud, donde el backend manda los días transcurridos en
/// lugar de la fecha del registro. Los valores negativos (futuro) se tratan
/// como "hoy".
String textoRelativoEnDias(int dias) {
  if (dias <= 0) return 'hoy';
  if (dias == 1) return 'ayer';
  if (dias < 7) return 'hace $dias días';
  if (dias < 30) {
    final semanas = dias ~/ 7;
    return semanas == 1 ? 'hace 1 semana' : 'hace $semanas semanas';
  }
  if (dias < 365) {
    final meses = dias ~/ 30;
    return meses == 1 ? 'hace 1 mes' : 'hace $meses meses';
  }
  return 'hace más de un año';
}

/// Trunca [fecha] a año-mes-día (medianoche local).
DateTime _soloFecha(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);
