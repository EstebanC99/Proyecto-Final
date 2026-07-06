import 'package:care_well_app/domain/entities/entities.dart';

class NotaEventoSalud extends BaseEntity {
  final int eventoSaludId;
  final EntidadBasica autor;
  final DateTime fechaHora;
  final String contenido;

  const NotaEventoSalud({
    required super.id,
    required this.eventoSaludId,
    required this.autor,
    required this.fechaHora,
    required this.contenido,
  });

  @override
  NotaEventoSalud copyWith({
    int? id,
    int? eventoSaludId,
    EntidadBasica? autor,
    DateTime? fechaHora,
    String? contenido,
  }) {
    return NotaEventoSalud(
      id: id ?? this.id,
      eventoSaludId: eventoSaludId ?? this.eventoSaludId,
      autor: autor ?? this.autor,
      fechaHora: fechaHora ?? this.fechaHora,
      contenido: contenido ?? this.contenido,
    );
  }
}
