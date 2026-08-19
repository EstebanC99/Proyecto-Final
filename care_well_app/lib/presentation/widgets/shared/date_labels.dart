/// Rótulos de fecha en español para la UI.
///
/// Funciones puras, sin `BuildContext` ni dependencias de Flutter, para que
/// puedan reutilizarse desde cualquier widget y testearse sin montar un árbol.
/// El "hoy" es inyectable en todas: los tests no dependen del reloj.
library;

/// Nombres de los días de la semana, indexados por `weekday - 1`.
const nombresDia = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

/// Nombres de los meses, indexados por `month - 1`.
const nombresMes = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Abreviaturas de tres letras de los días, indexadas por `weekday - 1`.
const nombresDiaCorto = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

/// Abreviaturas de tres letras de los meses, indexadas por `month - 1`.
const nombresMesCorto = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// Rótulo relativo de un día: "Hoy", "Mañana", "Ayer" o el nombre del día de
/// la semana para el resto.
///
/// Compara sólo la parte de fecha, así que la hora de [dia] y de [hoy] es
/// indiferente.
String rotuloRelativoDia(DateTime dia, {DateTime? hoy}) {
  final diferencia = _diasDeDiferencia(dia, hoy);
  return switch (diferencia) {
    0 => 'Hoy',
    1 => 'Mañana',
    -1 => 'Ayer',
    _ => nombresDia[dia.weekday - 1],
  };
}

/// Fecha corta con prefijo relativo: "Hoy, 17 ago", "Ayer, 16 ago" o
/// "15 ago" cuando el día no es ni hoy ni ayer.
///
/// Pensada para los campos de fecha de los formularios, donde el día concreto
/// tiene que verse siempre pero el caso frecuente es "hoy".
String fechaCortaRelativa(DateTime dia, {DateTime? hoy}) {
  final corta = '${dia.day} ${nombresMesCorto[dia.month - 1]}';
  return switch (_diasDeDiferencia(dia, hoy)) {
    0 => 'Hoy, $corta',
    1 => 'Mañana, $corta',
    -1 => 'Ayer, $corta',
    _ => corta,
  };
}

/// Días calendario entre [dia] y [hoy], ignorando la hora.
int _diasDeDiferencia(DateTime dia, DateTime? hoy) {
  final ahora = hoy ?? DateTime.now();
  final hoyTruncado = DateTime(ahora.year, ahora.month, ahora.day);
  final diaTruncado = DateTime(dia.year, dia.month, dia.day);
  return diaTruncado.difference(hoyTruncado).inDays;
}
