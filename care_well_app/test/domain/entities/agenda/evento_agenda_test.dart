import 'package:care_well_app/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

void main() {
  // ─── Fixture ────────────────────────────────────────────────────────────────

  final personaAlicia = Persona(
    id: 2,
    nombre: 'Alicia',
    apellido: 'Rodríguez',
    documento: "123123",
    fechaNacimiento: DateTime.now(),
  );

  final usuarioMaria = Usuario(
    id: 101,
    persona: Persona(
      id: 1,
      nombre: 'María',
      apellido: 'García',
      documento: "123123",
      fechaNacimiento: DateTime.now(),
    ),
    contrasena: 'hash123',
    estado: estadoUsuarioActivo,
  );

  EventoAgenda buildEvento(DateTime fechaHoraInicio) => EventoAgenda(
    id: 701,
    persona: personaAlicia,
    creadoPor: usuarioMaria,
    titulo: 'Evento de prueba',
    tipo: tipoEventoAgendaOtro,
    fechaHoraInicio: fechaHoraInicio,
  );

  group('EventoAgenda.estaVencido', () {
    test('retorna false cuando fechaHoraInicio es futura', () {
      final ahora = DateTime(2026, 6, 10, 10, 0);
      final evento = buildEvento(DateTime(2026, 6, 11, 10, 0));

      expect(evento.estaVencido(ahora), isFalse);
    });

    test('retorna true cuando fechaHoraInicio ya pasó', () {
      final ahora = DateTime(2026, 6, 10, 10, 0);
      final evento = buildEvento(DateTime(2026, 6, 9, 10, 0));

      expect(evento.estaVencido(ahora), isTrue);
    });

    test(
      'retorna true cuando fechaHoraInicio es igual a ahora (no es futura)',
      () {
        final ahora = DateTime(2026, 6, 10, 10, 0);
        final evento = buildEvento(ahora);

        expect(evento.estaVencido(ahora), isTrue);
      },
    );

    test('usa DateTime.now() cuando no se provee ahora', () {
      // Evento muy en el pasado: siempre vencido.
      final evento = buildEvento(DateTime(2020, 1, 1));
      expect(evento.estaVencido(), isTrue);
    });
  });

  group('EventoAgenda.esEditable', () {
    test('retorna true cuando el evento aún no venció', () {
      final ahora = DateTime(2026, 6, 10, 10, 0);
      final evento = buildEvento(DateTime(2026, 6, 11, 10, 0));

      expect(evento.esEditable(ahora), isTrue);
    });

    test('retorna false cuando el evento ya venció', () {
      final ahora = DateTime(2026, 6, 10, 10, 0);
      final evento = buildEvento(DateTime(2026, 6, 9, 10, 0));

      expect(evento.esEditable(ahora), isFalse);
    });

    test('es el complemento exacto de estaVencido', () {
      final ahora = DateTime(2026, 6, 10, 10, 0);
      final eventoFuturo = buildEvento(DateTime(2026, 6, 11, 10, 0));
      final eventoPasado = buildEvento(DateTime(2026, 6, 9, 10, 0));

      expect(eventoFuturo.esEditable(ahora), !eventoFuturo.estaVencido(ahora));
      expect(eventoPasado.esEditable(ahora), !eventoPasado.estaVencido(ahora));
    });
  });
}
