class AlertaBienestarModel {
  final String tipo;
  final String severidad;
  final String categoria;
  final String mensaje;
  final DateTime fechaDeteccion;
  final int? habitoVidaId;

  const AlertaBienestarModel({
    required this.tipo,
    required this.severidad,
    required this.categoria,
    required this.mensaje,
    required this.fechaDeteccion,
    this.habitoVidaId,
  });

  factory AlertaBienestarModel.fromJson(Map<String, dynamic> json) {
    return AlertaBienestarModel(
      tipo: json['tipo'] as String,
      severidad: json['severidad'] as String,
      categoria: json['categoria'] as String,
      mensaje: json['mensaje'] as String,
      fechaDeteccion: DateTime.parse(json['fechaDeteccion'] as String),
      habitoVidaId: json['habitoVidaID'] as int?,
    );
  }
}
