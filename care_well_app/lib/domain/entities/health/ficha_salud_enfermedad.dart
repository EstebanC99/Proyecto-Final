import 'package:care_well_app/domain/entities/entities.dart';

class FichaSaludEnfermedad extends BaseEntity {
  final String nombre;
  final bool vigente;
  final String? observacion;

  const FichaSaludEnfermedad({
    super.id = 0,
    required this.nombre,
    required this.vigente,
    this.observacion,
  });

  @override
  FichaSaludEnfermedad copyWith({
    int? id,
    String? nombre,
    bool? vigente,
    String? observacion,
  }) {
    return FichaSaludEnfermedad(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      vigente: vigente ?? this.vigente,
      observacion: observacion,
    );
  }
}
