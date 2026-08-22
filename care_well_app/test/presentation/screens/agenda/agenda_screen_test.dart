import 'dart:async';

import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/exceptions/exceptions.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/agenda/agenda_screen.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/fake_notification_scheduler.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _persona = Persona(
  id: 12,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _tipo = TipoEvento(id: 1, descripcion: 'Cita Médica');

/// Lunes de la semana en curso, base de todas las fechas de prueba.
final _lunes = () {
  final hoy = DateTime.now();
  final truncado = DateTime(hoy.year, hoy.month, hoy.day);
  return truncado.subtract(Duration(days: hoy.weekday - 1));
}();

OcurrenciaEventoAgenda _ocurrencia({
  required int id,
  required DateTime inicio,
  String? titulo,
  bool esRecurrente = false,
}) => OcurrenciaEventoAgenda(
  id: id,
  eventoAgendaId: id,
  personaId: _persona.id,
  titulo: titulo ?? 'Evento $id',
  tipo: _tipo,
  fechaHoraInicio: inicio,
  fechaHoraFin: inicio.add(const Duration(hours: 1)),
  esRecurrente: esRecurrente,
  generarEventoSalud: false,
);

// ─── Helper ───────────────────────────────────────────────────────────────────

/// Monta la pantalla con los providers de datos ya resueltos.
///
/// Se sobrescriben las vistas de ocurrencias (no el repositorio) para que el
/// test se concentre en el comportamiento de la pantalla.
Widget _wrap({
  List<OcurrenciaEventoAgenda> ocurrenciasSemana = const [],
  OcurrenciaEventoAgenda? proxima,
  bool puedeGestionar = true,

  /// Scheduler inyectado. Por defecto responde que las alarmas exactas están
  /// disponibles, para que el aviso no interfiera con el resto de los tests.
  FakeNotificationScheduler? scheduler,
  Persona? persona,
  List<Override> overrides = const [],
}) {
  final personaContexto = persona ?? _persona;
  return ProviderScope(
    overrides: [
      personaImagenProvider.overrideWith((ref, id) async => null),
      agendaPersonaContextProvider.overrideWith((ref) async => personaContexto),
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => personaContexto,
      ),
      personasSeleccionablesProvider.overrideWith(
        (ref) async => [
          PersonaContextOption(
            persona: personaContexto,
            rol: PersonaContextRol.propio,
          ),
        ],
      ),
      ocurrenciasDeSemanaProvider.overrideWith(
        (ref) async => ocurrenciasSemana,
      ),
      proximaOcurrenciaProvider.overrideWith((ref) async => proxima),
      puedeGestionarAgendaProvider.overrideWith((ref) async => puedeGestionar),
      notificationSchedulerProvider.overrideWithValue(
        scheduler ?? FakeNotificationScheduler(),
      ),
      ...overrides,
    ],
    child: const MaterialApp(home: AgendaScreen()),
  );
}

void main() {
  group('AgendaScreen', () {
    testWidgets('monta la tira de semana y el encabezado del día (smoke)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byType(WeekStrip), findsOneWidget);
      expect(find.byType(DayHeader), findsOneWidget);
      expect(find.text('HOY'), findsOneWidget);
    });

    testWidgets('no muestra el listado mensual colapsable ni la búsqueda', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byType(MonthNavHeader), findsNothing);
      expect(find.byIcon(Icons.search), findsNothing);
    });

    testWidgets('muestra solo las ocurrencias del día seleccionado', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ocurrenciasSemana: [
            _ocurrencia(
              id: 1,
              inicio: _lunes.add(const Duration(hours: 9)),
              titulo: 'Evento del lunes',
            ),
            _ocurrencia(
              id: 2,
              inicio: _lunes.add(const Duration(days: 2, hours: 10)),
              titulo: 'Evento del miércoles',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Por defecto el día seleccionado es hoy: se muestran sus eventos y no
      // los del resto de la semana.
      final hoy = DateTime.now();
      final esLunes = hoy.weekday == DateTime.monday;
      final esMiercoles = hoy.weekday == DateTime.wednesday;

      expect(
        find.text('Evento del lunes'),
        esLunes ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('Evento del miércoles'),
        esMiercoles ? findsOneWidget : findsNothing,
      );
    });

    testWidgets('al tocar otro día de la tira se muestran sus eventos', (
      tester,
    ) async {
      final miercoles = _lunes.add(const Duration(days: 2));
      await tester.pumpWidget(
        _wrap(
          ocurrenciasSemana: [
            _ocurrencia(
              id: 2,
              inicio: miercoles.add(const Duration(hours: 10)),
              titulo: 'Evento del miércoles',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('${miercoles.day}'));
      await tester.pumpAndSettle();

      expect(find.text('Evento del miércoles'), findsOneWidget);
    });

    testWidgets('el día sin eventos muestra el mensaje breve', (tester) async {
      final miercoles = _lunes.add(const Duration(days: 2));
      final jueves = _lunes.add(const Duration(days: 3));
      await tester.pumpWidget(
        _wrap(
          ocurrenciasSemana: [
            _ocurrencia(
              id: 2,
              inicio: miercoles.add(const Duration(hours: 10)),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('${jueves.day}'));
      await tester.pumpAndSettle();

      expect(find.text('No hay eventos este día'), findsOneWidget);
      // El estado vacío completo se reserva para semanas sin ningún evento.
      expect(find.byType(AgendaEmptyState), findsNothing);
    });

    testWidgets('la semana sin eventos muestra el estado vacío completo', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byType(AgendaEmptyState), findsOneWidget);
    });

    group('Lo que sigue', () {
      /// La sección va al final de la lista: hay que desplazarse para verla.
      Future<void> scrollALoQueSigue(WidgetTester tester) => tester
          .scrollUntilVisible(find.text('LO QUE SIGUE'), 200, maxScrolls: 20);

      testWidgets('muestra la próxima ocurrencia posterior al día', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            proxima: _ocurrencia(
              id: 9,
              inicio: _lunes.add(const Duration(days: 9, hours: 16)),
              titulo: 'Control clínico',
            ),
          ),
        );
        await tester.pumpAndSettle();
        await scrollALoQueSigue(tester);

        expect(find.text('LO QUE SIGUE'), findsOneWidget);
        expect(find.text('Control clínico'), findsOneWidget);
      });

      testWidgets('no se muestra cuando no hay ocurrencias posteriores', (
        tester,
      ) async {
        await tester.pumpWidget(_wrap());
        await tester.pumpAndSettle();

        expect(find.text('LO QUE SIGUE'), findsNothing);
      });

      testWidgets('al tocarla se navega al día de esa ocurrencia', (
        tester,
      ) async {
        final proximoDia = _lunes.add(const Duration(days: 9));
        await tester.pumpWidget(
          _wrap(
            proxima: _ocurrencia(
              id: 9,
              inicio: proximoDia.add(const Duration(hours: 16)),
              titulo: 'Control clínico',
            ),
          ),
        );
        await tester.pumpAndSettle();
        await scrollALoQueSigue(tester);
        // El rótulo de la sección puede quedar visible con la card todavía
        // por debajo del borde inferior: hay que asegurar la card en sí.
        await tester.ensureVisible(find.text('Control clínico'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Control clínico'));
        await tester.pumpAndSettle();

        // La tira ahora muestra la semana del evento y su día quedó activo.
        expect(find.text('${proximoDia.day}'), findsWidgets);
      });
    });

    // La baja de una serie ya iniciada se hace recortando desde la ocurrencia
    // elegida: el backend rechaza borrar el evento completo.
    group('eliminar esta y las siguientes', () {
      /// Ocurrencia recurrente del lunes que viene: siempre futura, así la
      /// tarjeta es accionable (las pasadas no abren la hoja de acciones).
      final proximoLunes = _lunes.add(const Duration(days: 7));
      final ocurrencia = _ocurrencia(
        id: 9,
        inicio: proximoLunes.add(const Duration(hours: 9)),
        titulo: 'Medicación diaria',
        esRecurrente: true,
      );

      /// Deja la pantalla con la hoja de acciones abierta sobre [ocurrencia].
      Future<void> abrirHoja(
        WidgetTester tester,
        List<Override> overrides,
      ) async {
        await tester.pumpWidget(
          _wrap(ocurrenciasSemana: [ocurrencia], overrides: overrides),
        );
        await tester.pumpAndSettle();

        // La agenda se abre en hoy: hay que ir a la semana de la ocurrencia y
        // pararse en su día.
        await tester.tap(
          find.descendant(
            of: find.byType(WeekStrip),
            matching: find.byIcon(Icons.chevron_right_rounded),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('${proximoLunes.day}'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Medicación diaria'));
        await tester.pumpAndSettle();
      }

      testWidgets('corta la serie desde la ocurrencia elegida', (tester) async {
        int? eventoRecibido;
        DateTime? fechaRecibida;

        await abrirHoja(tester, [
          cancelarSerieDesdeProvider.overrideWithValue(({
            required eventoAgendaId,
            required fechaOcurrencia,
          }) async {
            eventoRecibido = eventoAgendaId;
            fechaRecibida = fechaOcurrencia;
          }),
        ]);

        await tester.tap(find.text('Eliminar esta y las siguientes'));
        await tester.pumpAndSettle();

        // El diálogo aclara que lo anterior se conserva.
        expect(find.text('¿Eliminar esta y las siguientes?'), findsOneWidget);
        expect(
          find.textContaining('Las anteriores se conservan en el historial.'),
          findsOneWidget,
        );

        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        expect(eventoRecibido, 9);
        expect(fechaRecibida, ocurrencia.fechaHoraInicio);
        expect(
          find.text('Se eliminaron esta ocurrencia y las siguientes.'),
          findsOneWidget,
        );
      });

      // El backend valida la fecha y el tipo de evento: su mensaje es lo único
      // que explica por qué no se pudo.
      testWidgets('muestra el mensaje del backend cuando falla', (
        tester,
      ) async {
        await abrirHoja(tester, [
          cancelarSerieDesdeProvider.overrideWithValue(({
            required eventoAgendaId,
            required fechaOcurrencia,
          }) async {
            throw const ValidacionException(
              'No se puede eliminar una ocurrencia pasada.',
            );
          }),
        ]);

        await tester.tap(find.text('Eliminar esta y las siguientes'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        expect(
          find.text('No se puede eliminar una ocurrencia pasada.'),
          findsOneWidget,
        );
        // El diálogo se cerró: el aviso queda a la vista.
        expect(find.text('¿Eliminar esta y las siguientes?'), findsNothing);
      });
    });

    group('permisos', () {
      testWidgets('con permiso muestra el FAB con forma de squircle', (
        tester,
      ) async {
        await tester.pumpWidget(_wrap());
        await tester.pumpAndSettle();

        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab.shape, isA<RoundedRectangleBorder>());
      });

      testWidgets('sin permiso no muestra el FAB', (tester) async {
        await tester.pumpWidget(_wrap(puedeGestionar: false));
        await tester.pumpAndSettle();

        expect(find.byType(FloatingActionButton), findsNothing);
      });
    });

    // La selección de día y semana vive en providers globales: sin reinicio, la
    // agenda se reabría donde había quedado la visita anterior.
    group('reinicio de la selección', () {
      final haceUnMes = _lunes.subtract(const Duration(days: 28));

      testWidgets('al abrirse vuelve al día de hoy', (tester) async {
        await tester.pumpWidget(
          _wrap(
            overrides: [
              diaSeleccionadoProvider.overrideWith((ref) => haceUnMes),
              semanaSeleccionadaProvider.overrideWith((ref) => haceUnMes),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('HOY'), findsOneWidget);
      });

      testWidgets('la semana visible también vuelve a la actual', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            overrides: [
              semanaSeleccionadaProvider.overrideWith((ref) => haceUnMes),
            ],
          ),
        );
        await tester.pumpAndSettle();

        final container = ProviderScope.containerOf(
          tester.element(find.byType(AgendaScreen)),
        );
        expect(container.read(semanaSeleccionadaProvider), _lunes);
      });
    });

    group('aviso de alarmas exactas', () {
      const mensaje =
          'Los recordatorios de la agenda podrían llegar tarde. Activá las '
          'alarmas exactas para que avisen a tiempo.';

      FakeNotificationScheduler fake({bool puedeExactas = false}) {
        final scheduler = FakeNotificationScheduler(
          puedeAlarmasExactas: puedeExactas,
        );
        addTearDown(scheduler.dispose);
        return scheduler;
      }

      testWidgets('sin alarmas exactas se muestra el aviso', (tester) async {
        await tester.pumpWidget(_wrap(scheduler: fake()));
        await tester.pumpAndSettle();

        expect(find.text(mensaje), findsOneWidget);
        expect(find.byIcon(Icons.alarm_off_outlined), findsOneWidget);
        expect(find.text('Activar'), findsOneWidget);
      });

      testWidgets('con alarmas exactas no se muestra nada', (tester) async {
        await tester.pumpWidget(_wrap(scheduler: fake(puedeExactas: true)));
        await tester.pumpAndSettle();

        expect(find.text(mensaje), findsNothing);
      });

      testWidgets('mientras el permiso no se resolvió el aviso se calla', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            overrides: [
              // Sin resolver: representa tanto la carga como una falla del
              // chequeo. En ambos casos la agenda no debe mostrar ruido.
              puedeProgramarAlarmasExactasProvider.overrideWith(
                (ref) => Completer<bool>().future,
              ),
            ],
          ),
        );
        await tester.pump();

        expect(find.text(mensaje), findsNothing);
      });

      testWidgets('al descartarlo desaparece', (tester) async {
        await tester.pumpWidget(_wrap(scheduler: fake()));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Descartar aviso'));
        await tester.pumpAndSettle();

        expect(find.text(mensaje), findsNothing);
      });

      testWidgets('Activar delega en el scheduler la apertura de Ajustes', (
        tester,
      ) async {
        final scheduler = fake();
        await tester.pumpWidget(_wrap(scheduler: scheduler));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Activar'));
        await tester.pumpAndSettle();

        expect(scheduler.solicitarAlarmasExactasCount, 1);
      });

      testWidgets('al volver de Ajustes con el permiso activo se va solo', (
        tester,
      ) async {
        final scheduler = fake();
        await tester.pumpWidget(_wrap(scheduler: scheduler));
        await tester.pumpAndSettle();
        expect(find.text(mensaje), findsOneWidget);

        // El usuario activa el permiso en Ajustes: la pantalla del sistema no
        // devuelve resultado, así que el aviso solo puede irse si la vuelta a
        // foreground vuelve a consultar.
        scheduler.puedeAlarmasExactas = true;
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        expect(find.text(mensaje), findsNothing);
      });
    });
  });
}
