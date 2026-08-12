/// DTO de lectura del resumen inteligente (US 9.16).
///
/// Espeja `ResumenDiarioDataView` del backend. El parseo es deliberadamente
/// defensivo: buena parte del contenido lo redacta un modelo de IA, así que
/// campos faltantes, listas nulas o tipos inesperados no deben tumbar la app.
/// La normalización *semántica* (los "Sin registros", el formato de la hora, el
/// orden de los eventos) no vive acá sino en `ResumenInteligenteMapper`.
class ResumenInteligenteModel {
  final String? resumenAcotado;
  final String? estadoAnimo;
  final String? resumenHabitos;
  final List<ResumenDiarioHabitoModel> habitos;
  final List<ResumenDiarioEventoSaludModel> eventosSalud;
  final List<String> recomendaciones;
  final List<String> recordatoriosHoy;
  final List<String> recordatoriosManana;
  final List<ResumenDiarioHabitoModel> habitosManana;
  final DateTime? generadoEn;
  final bool tieneDatos;

  const ResumenInteligenteModel({
    this.resumenAcotado,
    this.estadoAnimo,
    this.resumenHabitos,
    this.habitos = const [],
    this.eventosSalud = const [],
    this.recomendaciones = const [],
    this.recordatoriosHoy = const [],
    this.recordatoriosManana = const [],
    this.habitosManana = const [],
    this.generadoEn,
    required this.tieneDatos,
  });

  factory ResumenInteligenteModel.fromJson(Map<String, dynamic> json) {
    final habitos = _listaDe(
      json['habitos'],
      ResumenDiarioHabitoModel.fromJson,
    );
    final eventosSalud = _listaDe(
      json['eventosSalud'],
      ResumenDiarioEventoSaludModel.fromJson,
    );
    final recomendaciones = _listaDeTextos(json['recomendaciones']);
    final recordatoriosHoy = _listaDeTextos(json['recordatoriosHoy']);
    final recordatoriosManana = _listaDeTextos(json['recordatoriosManana']);
    final habitosManana = _listaDe(
      json['habitosManana'],
      ResumenDiarioHabitoModel.fromJson,
    );

    final resumenAcotado = _texto(json['resumenAcotado']);
    final estadoAnimo = _texto(json['estadoAnimo']);
    final resumenHabitos = _texto(json['resumenHabitos']);

    return ResumenInteligenteModel(
      resumenAcotado: resumenAcotado,
      estadoAnimo: estadoAnimo,
      resumenHabitos: resumenHabitos,
      habitos: habitos,
      eventosSalud: eventosSalud,
      recomendaciones: recomendaciones,
      recordatoriosHoy: recordatoriosHoy,
      recordatoriosManana: recordatoriosManana,
      habitosManana: habitosManana,
      generadoEn: _fecha(json['generadoEn']),
      // El backend lo calcula y lo serializa, pero si faltara se deriva con la
      // misma regla en lugar de castear a bool y explotar.
      tieneDatos: json['tieneDatos'] is bool
          ? json['tieneDatos'] as bool
          : resumenAcotado != null ||
                estadoAnimo != null ||
                resumenHabitos != null ||
                habitos.isNotEmpty ||
                eventosSalud.isNotEmpty ||
                recomendaciones.isNotEmpty ||
                recordatoriosHoy.isNotEmpty ||
                recordatoriosManana.isNotEmpty ||
                habitosManana.isNotEmpty,
    );
  }

  /// Devuelve el texto solo si es una cadena no vacía; en cualquier otro caso,
  /// `null`.
  static String? _texto(Object? valor) {
    if (valor is! String) return null;
    return valor.trim().isEmpty ? null : valor;
  }

  /// Parsea una fecha ISO tolerando ausencias y valores no interpretables.
  /// `DateTime.MinValue` de .NET ("0001-01-01…") se descarta: no es una fecha
  /// real de generación.
  static DateTime? _fecha(Object? valor) {
    if (valor is! String) return null;
    final fecha = DateTime.tryParse(valor);
    if (fecha == null || fecha.year <= 1) return null;
    return fecha;
  }

  /// Mapea una lista de objetos JSON, salteando los elementos con otra forma.
  static List<T> _listaDe<T>(
    Object? valor,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (valor is! List) return const [];
    return valor
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }

  /// Mapea una lista de strings, descartando nulos, no-strings y vacíos.
  static List<String> _listaDeTextos(Object? valor) {
    if (valor is! List) return const [];
    return valor
        .whereType<String>()
        .where((texto) => texto.trim().isNotEmpty)
        .toList(growable: false);
  }
}

/// Hábito dentro del resumen diario (hoy o mañana).
class ResumenDiarioHabitoModel {
  final String? descripcion;
  final bool completado;

  const ResumenDiarioHabitoModel({this.descripcion, this.completado = false});

  factory ResumenDiarioHabitoModel.fromJson(Map<String, dynamic> json) {
    return ResumenDiarioHabitoModel(
      descripcion: ResumenInteligenteModel._texto(json['descripcion']),
      completado: json['completado'] is bool
          ? json['completado'] as bool
          : false,
    );
  }
}

/// Evento de salud dentro del resumen diario.
class ResumenDiarioEventoSaludModel {
  final String? descripcion;
  final String? hora;
  final String? actividadHabitoAsociado;

  const ResumenDiarioEventoSaludModel({
    this.descripcion,
    this.hora,
    this.actividadHabitoAsociado,
  });

  factory ResumenDiarioEventoSaludModel.fromJson(Map<String, dynamic> json) {
    return ResumenDiarioEventoSaludModel(
      descripcion: ResumenInteligenteModel._texto(json['descripcion']),
      hora: ResumenInteligenteModel._texto(json['hora']),
      actividadHabitoAsociado: ResumenInteligenteModel._texto(
        json['actividadHabitoAsociado'],
      ),
    );
  }
}
