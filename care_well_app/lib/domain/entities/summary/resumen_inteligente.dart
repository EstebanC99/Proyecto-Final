import 'package:care_well_app/domain/entities/entities.dart';

/// Resumen inteligente de la persona a cargo (US 9.16): vista estructurada del
/// día, redactada por un componente de IA generativa a partir de los eventos de
/// salud, los hábitos de vida, los estados de ánimo y la agenda.
///
/// No extiende `BaseEntity` a propósito (mismo criterio que [AlertaBienestar]):
/// es un read-model **efímero**, generado on-demand y **no persistido**. No
/// tiene identidad propia. Es inmutable.
///
/// Los campos de texto son `null` cuando el backend no tenía nada que reportar
/// para ese origen: el mapper traduce ahí los "Sin registros" y las cadenas
/// vacías, para que la presentación decida solo por `null`.
class ResumenInteligente {
  /// Vista previa de 2-3 oraciones del día. Destinada al hero del Home.
  final String? resumenAcotado;

  /// Estado de ánimo del día, ya redactado (ej. "Alegre y con energía").
  final String? estadoAnimo;

  /// Comentario redactado sobre el cumplimiento de los hábitos del día.
  final String? resumenHabitos;

  /// Hábitos previstos para hoy, con su estado de cumplimiento.
  final List<HabitoResumen> habitos;

  /// Eventos de salud registrados hoy, ordenados por hora ascendente (los que
  /// no tienen hora quedan al final).
  final List<EventoSaludResumen> eventosSalud;

  /// Sugerencias de seguimiento generadas por la IA. Nunca son diagnósticos.
  final List<String> recomendaciones;

  /// Compromisos de agenda de hoy que todavía no ocurrieron.
  final List<String> recordatoriosHoy;

  /// Compromisos de agenda previstos para mañana.
  final List<String> recordatoriosManana;

  /// Hábitos previstos para mañana (siempre pendientes).
  final List<HabitoResumen> habitosManana;

  /// Momento en que se generó el resumen (lo fija el backend en cada consulta).
  /// Es `null` cuando la fecha recibida no era utilizable.
  final DateTime? generadoEn;

  /// Indica si hubo información en alguno de los orígenes del día. Cuando es
  /// `false`, la UI muestra el estado vacío en lugar del resumen.
  final bool tieneDatos;

  const ResumenInteligente({
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

  /// Cantidad de hábitos previstos para hoy.
  int get totalHabitos => habitos.length;

  /// Cantidad de hábitos de hoy ya registrados como realizados.
  int get habitosCompletados =>
      habitos.where((habito) => habito.completado).length;

  /// Avance de los hábitos de hoy, entre 0.0 y 1.0. Vale 0.0 cuando no hay
  /// hábitos previstos (no se divide por cero).
  double get progresoHabitos =>
      totalHabitos == 0 ? 0.0 : habitosCompletados / totalHabitos;

  /// `true` cuando hay algo que señalar al cuidador: recomendaciones de la IA o
  /// compromisos de hoy todavía pendientes.
  bool get hayAtencion =>
      recomendaciones.isNotEmpty || recordatoriosHoy.isNotEmpty;

  /// `true` cuando hay algo para adelantar sobre el día siguiente.
  bool get hayManana =>
      recordatoriosManana.isNotEmpty || habitosManana.isNotEmpty;

  /// Hay algo que decir sobre los hábitos de hoy: la lista o el comentario.
  bool get hayHabitos => habitos.isNotEmpty || resumenHabitos != null;

  /// `true` cuando hay al menos una sección con contenido para mostrar.
  /// Distinto de [tieneDatos]: este mira solo lo que la pantalla realmente
  /// pinta ([resumenAcotado] alimenta el hero del Home, no esa pantalla).
  bool get hayContenidoVisible =>
      estadoAnimo != null ||
      hayHabitos ||
      eventosSalud.isNotEmpty ||
      hayAtencion ||
      hayManana;
}
