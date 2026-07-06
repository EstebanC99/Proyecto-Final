import 'package:care_well_app/domain/entities/base_entity.dart';

class EventoBase extends BaseEntity {
  final String descripcion;
  final String categoriaEvento;
  final DateTime fechaHora;

  const EventoBase({
    required super.id,
    required this.descripcion,
    required this.categoriaEvento,
    required this.fechaHora,
  });

  @override
  BaseEntity copyWith({
    int? id,
    String? descripcion,
    String? categoriaEvento,
    DateTime? fechaHora,
  }) {
    return EventoBase(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      categoriaEvento: categoriaEvento ?? this.categoriaEvento,
      fechaHora: fechaHora ?? this.fechaHora,
    );
  }
}
