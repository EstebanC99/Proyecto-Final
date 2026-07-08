import 'package:care_well_app/domain/entities/entities.dart';

class FichaSaludAntecedente extends BaseEntity {
  final String nombre;
  final String descripcion;
  final String vinculoFamiliar;

  const FichaSaludAntecedente({
    super.id = 0,
    required this.nombre,
    required this.descripcion,
    required this.vinculoFamiliar,
  });

  @override
  FichaSaludAntecedente copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? vinculoFamiliar,
  }) {
    return FichaSaludAntecedente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      vinculoFamiliar: vinculoFamiliar ?? this.vinculoFamiliar,
    );
  }
}
