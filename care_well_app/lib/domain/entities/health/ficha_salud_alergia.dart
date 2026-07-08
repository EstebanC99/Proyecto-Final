import 'package:care_well_app/domain/entities/entities.dart';

class FichaSaludAlergia extends BaseEntity {
  final String nombre;
  final String reaccion;
  final String? medicamento;

  const FichaSaludAlergia({
    super.id = 0,
    required this.nombre,
    required this.reaccion,
    this.medicamento,
  });

  @override
  FichaSaludAlergia copyWith({
    int? id,
    String? nombre,
    String? reaccion,
    String? medicamento,
  }) {
    return FichaSaludAlergia(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      reaccion: reaccion ?? this.reaccion,
      medicamento: medicamento,
    );
  }
}
