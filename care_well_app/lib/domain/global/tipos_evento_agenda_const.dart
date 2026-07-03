/// IDs de los tipos de evento de la agenda (catálogo del backend).
///
/// Espejo del enumerado [TiposEventoAgenda] del backend.
/// Los 13 tipos corresponden a la tabla de catálogo; [otro] actúa como
/// valor por defecto cuando el tipo no se identifica.
abstract final class TiposEventoAgendaConst {
  static const int citaMedica = 1;
  static const int medicacion = 2;
  static const int rehabilitacion = 3;
  static const int control = 4;
  static const int hospitalizacion = 5;
  static const int cirugia = 6;
  static const int tratamiento = 7;
  static const int bienestar = 8;
  static const int sintoma = 9;
  static const int diagnostico = 10;
  static const int vacuna = 11;
  static const int actividadFisica = 12;
  static const int otro = 13;
}
