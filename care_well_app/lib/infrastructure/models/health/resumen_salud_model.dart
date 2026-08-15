/// DTO de `ResumenSaludDataView` (endpoint `ResumenSalud/obtener`).
///
/// Todos los campos son opcionales: el backend devuelve nulos cuando la persona
/// no tiene ficha, hábitos, ánimo de hoy o eventos.
class ResumenSaludModel {
  final String? grupoSanguineo;
  final int? cantidadAlergias;
  final int? cantidadAntecedentes;
  final int? cantidadEnfermedades;
  final int? cantidadHabitosCompletados;
  final int? cantidadHabitos;
  final int? estadoAnimoId;
  final String? ultimoEventoSalud;
  final int? cantidadDias;

  const ResumenSaludModel({
    this.grupoSanguineo,
    this.cantidadAlergias,
    this.cantidadAntecedentes,
    this.cantidadEnfermedades,
    this.cantidadHabitosCompletados,
    this.cantidadHabitos,
    this.estadoAnimoId,
    this.ultimoEventoSalud,
    this.cantidadDias,
  });

  factory ResumenSaludModel.fromJson(Map<String, dynamic> json) {
    return ResumenSaludModel(
      grupoSanguineo: json['grupoSanguineo'] as String?,
      cantidadAlergias: json['cantidadAlergias'] as int?,
      cantidadAntecedentes: json['cantidadAntecedentes'] as int?,
      cantidadEnfermedades: json['cantidadEnfermedades'] as int?,
      cantidadHabitosCompletados: json['cantidadHabitosCompletados'] as int?,
      cantidadHabitos: json['cantidadHabitos'] as int?,
      estadoAnimoId: json['estadoAnimoID'] as int?,
      ultimoEventoSalud: json['ultimoEventoSalud'] as String?,
      cantidadDias: json['cantidadDias'] as int?,
    );
  }
}
