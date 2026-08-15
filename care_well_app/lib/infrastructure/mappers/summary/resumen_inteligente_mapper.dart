import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

/// Traduce el DTO del resumen diario a la entidad de dominio, normalizando la
/// semántica del contenido generado por IA.
///
/// Todo lo "sucio" del contrato se resuelve acá y no en la presentación:
/// - los centinelas del prompt ("Sin registros") y los textos vacíos pasan a
///   `null`;
/// - la hora de cada evento se normaliza a "HH:mm" o se descarta si el modelo
///   no respetó el formato;
/// - los eventos de salud se ordenan por hora ascendente y los que no tienen
///   hora quedan al final;
/// - los ítems sin descripción se descartan (no hay nada que mostrar).
class ResumenInteligenteMapper {
  ResumenInteligenteMapper._();

  /// Centinela que usa el prompt del backend cuando no hay datos de un origen.
  static const String _sinRegistros = 'sin registros';

  /// Hora "H:mm" u "HH:mm:ss" al inicio del texto.
  static final RegExp _formatoHora = RegExp(r'^(\d{1,2}):(\d{2})');

  static ResumenInteligente fromModel(ResumenInteligenteModel model) {
    final resumenAcotado = _normalizarTexto(model.resumenAcotado);
    final estadoAnimo = _normalizarTexto(model.estadoAnimo);
    final resumenHabitos = _normalizarTexto(model.resumenHabitos);
    final habitos = _habitos(model.habitos);
    final eventosSalud = _ordenarPorHora(
      model.eventosSalud
          .map(_eventoSalud)
          .whereType<EventoSaludResumen>()
          .toList(),
    );
    final recomendaciones = _normalizarTextos(model.recomendaciones);
    final recordatoriosHoy = _normalizarTextos(model.recordatoriosHoy);
    final recordatoriosManana = _normalizarTextos(model.recordatoriosManana);
    final habitosManana = _habitos(model.habitosManana);

    return ResumenInteligente(
      resumenAcotado: resumenAcotado,
      estadoAnimo: estadoAnimo,
      resumenHabitos: resumenHabitos,
      habitos: habitos,
      eventosSalud: eventosSalud,
      recomendaciones: recomendaciones,
      recordatoriosHoy: recordatoriosHoy,
      recordatoriosManana: recordatoriosManana,
      habitosManana: habitosManana,
      generadoEn: model.generadoEn,
      // Espejo fiel de lo que informó el backend. Qué se puede *mostrar* es
      // otra pregunta y la responde la entidad con `hayContenidoVisible`.
      tieneDatos: model.tieneDatos,
    );
  }

  /// Devuelve el texto recortado, o `null` si está vacío o es el centinela
  /// "Sin registros".
  static String? _normalizarTexto(String? texto) {
    if (texto == null) return null;
    final limpio = texto.trim();
    if (limpio.isEmpty) return null;
    if (limpio.toLowerCase() == _sinRegistros) return null;
    return limpio;
  }

  /// Aplica [_normalizarTexto] a cada elemento y descarta los que quedan nulos.
  static List<String> _normalizarTextos(List<String> textos) {
    return textos
        .map(_normalizarTexto)
        .whereType<String>()
        .toList(growable: false);
  }

  static List<HabitoResumen> _habitos(List<ResumenDiarioHabitoModel> modelos) {
    return modelos
        .map((modelo) {
          final descripcion = _normalizarTexto(modelo.descripcion);
          if (descripcion == null) return null;
          return HabitoResumen(
            descripcion: descripcion,
            completado: modelo.completado,
          );
        })
        .whereType<HabitoResumen>()
        .toList(growable: false);
  }

  static EventoSaludResumen? _eventoSalud(
    ResumenDiarioEventoSaludModel modelo,
  ) {
    final descripcion = _normalizarTexto(modelo.descripcion);
    if (descripcion == null) return null;
    return EventoSaludResumen(
      descripcion: descripcion,
      hora: _normalizarHora(modelo.hora),
      actividadHabitoAsociado: _normalizarTexto(modelo.actividadHabitoAsociado),
    );
  }

  /// Normaliza la hora a "HH:mm". La escribe el modelo de IA, así que puede
  /// venir con otro formato o directamente ausente: en ese caso devuelve `null`
  /// y la UI muestra el evento sin hora.
  static String? _normalizarHora(String? hora) {
    final limpio = _normalizarTexto(hora);
    if (limpio == null) return null;

    final match = _formatoHora.firstMatch(limpio);
    if (match == null) return null;

    final horas = int.parse(match.group(1)!);
    final minutos = int.parse(match.group(2)!);
    if (horas > 23 || minutos > 59) return null;

    final hh = horas.toString().padLeft(2, '0');
    final mm = minutos.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  /// Ordena por hora ascendente dejando al final los eventos sin hora, y
  /// preservando el orden original entre elementos equivalentes (el `sort` de
  /// Dart no es estable, por eso se ordena decorando con el índice).
  static List<EventoSaludResumen> _ordenarPorHora(
    List<EventoSaludResumen> eventos,
  ) {
    final indexados = eventos.indexed.toList();
    indexados.sort((a, b) {
      final horaA = a.$2.hora;
      final horaB = b.$2.hora;
      if (horaA == null && horaB == null) return a.$1.compareTo(b.$1);
      if (horaA == null) return 1;
      if (horaB == null) return -1;
      final porHora = horaA.compareTo(horaB);
      return porHora != 0 ? porHora : a.$1.compareTo(b.$1);
    });
    return indexados.map((par) => par.$2).toList(growable: false);
  }
}
