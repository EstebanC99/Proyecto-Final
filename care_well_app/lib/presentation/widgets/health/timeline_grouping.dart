import '../../../domain/entities/entities.dart';

/// Registros de un mismo día calendario en la línea de tiempo de salud.
class GrupoDiaTimeline {
  const GrupoDiaTimeline({required this.dia, required this.eventos});

  /// Día del grupo, truncado a año-mes-día en hora local.
  final DateTime dia;

  /// Registros de ese día, en orden cronológico ascendente.
  final List<EventoBase> eventos;
}

/// Agrupa los registros de la línea de tiempo por día calendario.
///
/// Los días quedan en orden **descendente** (el más reciente primero, que es lo
/// que el usuario quiere ver al entrar) y, dentro de cada día, los registros en
/// orden **ascendente**: la jornada se lee de la mañana a la noche.
///
/// El truncado se hace **después** de pasar a hora local. Un registro guardado
/// en UTC cerca de medianoche pertenece a otro día si se trunca antes de
/// convertir.
///
/// Es una función pura: no depende del reloj ni del árbol de widgets.
List<GrupoDiaTimeline> agruparPorDia(List<EventoBase> eventos) {
  final porDia = <DateTime, List<EventoBase>>{};

  for (final evento in eventos) {
    final local = evento.fechaHora.toLocal();
    final dia = DateTime(local.year, local.month, local.day);
    porDia.putIfAbsent(dia, () => []).add(evento);
  }

  final dias = porDia.keys.toList()..sort((a, b) => b.compareTo(a));

  return [
    for (final dia in dias)
      GrupoDiaTimeline(
        dia: dia,
        eventos: porDia[dia]!
          ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora)),
      ),
  ];
}
