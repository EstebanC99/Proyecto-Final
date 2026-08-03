/// DTO de lectura del resumen inteligente (US 9.16).
///
/// Contrato acordado con el backend: `{texto, tieneDatos, generadoEn}`.
class ResumenInteligenteModel {
  final String? texto;
  final bool tieneDatos;
  final DateTime generadoEn;

  const ResumenInteligenteModel({
    required this.texto,
    required this.tieneDatos,
    required this.generadoEn,
  });

  factory ResumenInteligenteModel.fromJson(Map<String, dynamic> json) {
    return ResumenInteligenteModel(
      texto: json['texto'] as String?,
      tieneDatos: json['tieneDatos'] as bool,
      generadoEn: DateTime.parse(json['generadoEn'] as String),
    );
  }
}
