import 'dart:async';

import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/exceptions/exceptions.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/home/home_screen.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fake repositories ────────────────────────────────────────────────────────

class _FakeAuthRepository implements AuthRepository {
  final Usuario? _usuario;
  _FakeAuthRepository(this._usuario);

  @override
  Future<Usuario> login(String email, String contrasena) async => _usuario!;

  @override
  Future<void> register(RegistroData data) async {}

  @override
  Future<void> solicitarRecuperacionContrasena(String email) async {}

  @override
  Future<void> confirmarResetContrasena({
    required String email,
    required String codigo,
    required String contrasenaNueva,
  }) async {}

  @override
  Future<void> reenviarCodigoVerificacion(String email) async {}

  @override
  Future<void> verificarEmail(String email, String codigo) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> eliminarCuenta() async {}

  @override
  Future<void> cambiarContrasena({
    required int usuarioId,
    required String contrasenaActual,
    required String contrasenaNueva,
  }) async {}

  @override
  Future<void> crearCredenciales({
    required String email,
    required String contrasena,
    required String imagenDocumento,
  }) async {}
}

/// Fake de [SummaryRepository]: devuelve un resumen fijo, falla o se queda
/// colgado. El Home depende de él para la card hero (US 9.16), así que todos
/// los tests lo sobrescriben para no golpear la API real.
class _FakeSummaryRepository implements SummaryRepository {
  _FakeSummaryRepository.conResumen(this._resumen)
    : _falla = false,
      _colgado = false;
  _FakeSummaryRepository.queFalla()
    : _resumen = null,
      _falla = true,
      _colgado = false;
  _FakeSummaryRepository.queNuncaResponde()
    : _resumen = null,
      _falla = false,
      _colgado = true;

  final ResumenInteligente? _resumen;
  final bool _falla;
  final bool _colgado;

  @override
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    bool forzarActualizacion = false,
  }) {
    if (_colgado) return Completer<ResumenInteligente>().future;
    if (_falla) return Future.error(const ServidorException());
    return Future.value(_resumen!);
  }
}

// ─── Datos de prueba ─────────────────────────────────────────────────────────

final _testUsuario = Usuario(
  id: 101,
  persona: Persona(
    id: 1,
    nombre: 'María',
    apellido: 'García',
    documento: '28000001',
    fechaNacimiento: DateTime(1990, 1, 1),
    email: 'maria@example.com',
  ),
  contrasena: '1234',
  estado: EstadoUsuario(id: EstadosUsuarioConst.activo, descripcion: 'Activo'),
);

final _testDependiente = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

/// Construye una AsignacionCuidado de prueba a partir de una Persona.
AsignacionCuidado _asignacionDesde(Persona persona) => AsignacionCuidado(
  id: 401,
  personaCuidada: persona,
  colaborador: _testUsuario.persona,
  rol: RolCuidado(
    id: RolesCuidadoConst.responsable,
    descripcion: 'Responsable',
  ),
  estado: EstadoAsignacionCuidado(
    id: EstadosAsignacionConst.activa,
    descripcion: 'Activa',
  ),
  fechaAlta: DateTime(2024, 1, 8),
);

// ─── Helper ──────────────────────────────────────────────────────────────────

/// Resumen por defecto de la card hero en los tests.
final _resumenDePrueba = ResumenInteligente(
  resumenAcotado: 'Alicia tuvo una jornada tranquila.',
  tieneDatos: true,
  generadoEn: DateTime(2026, 8, 13, 9, 5),
);

/// Construye el widget con los providers sobrescritos directamente
/// para evitar el estado de carga y los timers del skeleton en tests.
Widget _wrap({
  required List<AsignacionCuidado> asignaciones,
  Override? animoOverride,
  Override? personasOverride,
  SummaryRepository? summaryRepository,
}) {
  return ProviderScope(
    overrides: [
      // Evita que los avatares (header y selector de contexto) golpeen el
      // repositorio real: caen al fallback de iniciales.
      personaImagenProvider.overrideWith((ref, id) async => null),
      authRepositoryProvider.overrideWithValue(
        _FakeAuthRepository(_testUsuario),
      ),
      // Sobrescribe authStateProvider con un usuario ya autenticado.
      authStateProvider.overrideWith(
        (ref) =>
            AuthNotifier(ref.watch(authRepositoryProvider))
              ..login(_testUsuario.persona.email!, _testUsuario.contrasena),
      ),
      // Sobrescribe assignmentsAsResponsableProvider directamente para evitar el loading
      // state, lo que evita que se monte NavTileSkeleton y sus timers infinitos.
      asignacionesActivasComoResponsableProvider.overrideWith(
        (ref) async => asignaciones,
      ),
      asignacionesActivasComoCuidadorProvider.overrideWith(
        (ref) async => <AsignacionCuidado>[],
      ),
      // Sin ánimo de hoy en tests (por defecto): el badge muestra '?' (neutro).
      animoOverride ?? animoHoyProvider.overrideWith((ref) async => null),
      // La card hero pide el resumen inteligente al abrir el Home: sin este
      // override los tests intentarían pegarle a la API real.
      summaryRepositoryProvider.overrideWithValue(
        summaryRepository ??
            _FakeSummaryRepository.conResumen(_resumenDePrueba),
      ),
      ?personasOverride,
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

/// Avanza el tiempo suficiente para que todas las animaciones de entrada
/// (animate_do: FadeIn 400ms + delay máx 400ms) concluyan.
Future<void> _settleAnimations(WidgetTester tester) async {
  await tester.pump(); // resuelve FutureProvider
  await tester.pump(
    const Duration(milliseconds: 900),
  ); // animaciones de entrada
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('HomeScreen', () {
    testWidgets('monta sin errores (smoke)', (tester) async {
      await tester.pumpWidget(
        _wrap(asignaciones: [_asignacionDesde(_testDependiente)]),
      );
      await _settleAnimations(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Caso 1 — lista no vacía muestra NavTile de personas a cargo', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(asignaciones: [_asignacionDesde(_testDependiente)]),
      );
      await _settleAnimations(tester);

      expect(find.text('Personas a cargo'), findsOneWidget);
      expect(find.byType(EmptyStateTile), findsNothing);
    });

    testWidgets('Caso 2 — lista vacía muestra EmptyStateTile', (tester) async {
      await tester.pumpWidget(_wrap(asignaciones: []));
      await _settleAnimations(tester);

      expect(find.byType(EmptyStateTile), findsOneWidget);
      // El NavTile de personas no debe aparecer con lista vacía
      expect(find.text('Personas a cargo'), findsNothing);
    });

    testWidgets('Caso 3 — HomeHeader se renderiza', (tester) async {
      await tester.pumpWidget(_wrap(asignaciones: []));
      await _settleAnimations(tester);

      expect(find.byType(HomeHeader), findsOneWidget);
    });

    testWidgets('Caso 3b — nombre del usuario aparece en el header', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(asignaciones: []));
      await _settleAnimations(tester);

      // El header debe mostrar el nombre del usuario autenticado
      expect(find.textContaining('María'), findsWidgets);
    });

    testWidgets('EmergencyTile siempre visible con lista vacía', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(asignaciones: []));
      await _settleAnimations(tester);
      expect(find.byType(EmergencyTile), findsOneWidget);
    });

    testWidgets('EmergencyTile siempre visible con datos', (tester) async {
      await tester.pumpWidget(
        _wrap(asignaciones: [_asignacionDesde(_testDependiente)]),
      );
      await _settleAnimations(tester);
      expect(find.byType(EmergencyTile), findsOneWidget);
    });

    testWidgets('tiles fijos del grid siempre se muestran', (tester) async {
      await tester.pumpWidget(
        _wrap(asignaciones: [_asignacionDesde(_testDependiente)]),
      );
      await _settleAnimations(tester);

      expect(find.text('Calendario'), findsOneWidget);
      expect(find.text('Equipo de cuidado'), findsOneWidget);
      expect(find.text('Salud'), findsOneWidget);
    });

    testWidgets('los tiles del grid muestran su descripción', (tester) async {
      await tester.pumpWidget(
        _wrap(asignaciones: [_asignacionDesde(_testDependiente)]),
      );
      await _settleAnimations(tester);

      expect(find.text('Turnos y eventos'), findsOneWidget);
      expect(find.text('Quién ayuda y cómo'), findsOneWidget);
      expect(find.text('Perfiles que cuidás'), findsOneWidget);
      expect(find.text('Registros y estado'), findsOneWidget);
    });

    testWidgets('badge de ánimo muestra "?" cuando no hay registro hoy', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(asignaciones: [_asignacionDesde(_testDependiente)]),
      );
      await _settleAnimations(tester);

      // Con animoHoy == null el badge del NavTile de Salud muestra '?'.
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets(
      'badge de ánimo muestra "?" cuando la consulta falla (no queda pegado)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            asignaciones: [_asignacionDesde(_testDependiente)],
            // Simula que la consulta del ánimo de la nueva persona termina en
            // error: el badge no debe conservar un emoji previo, debe mostrar '?'.
            animoOverride: animoHoyProvider.overrideWith(
              (ref) async => throw Exception('sin datos'),
            ),
          ),
        );
        await _settleAnimations(tester);

        expect(find.text('?'), findsOneWidget);
      },
    );

    group('card del resumen inteligente', () {
      testWidgets('mientras se genera muestra "Generando…"', (tester) async {
        await tester.pumpWidget(
          _wrap(
            asignaciones: [_asignacionDesde(_testDependiente)],
            summaryRepository: _FakeSummaryRepository.queNuncaResponde(),
          ),
        );
        await _settleAnimations(tester);

        expect(find.text('Generando…'), findsOneWidget);
        expect(find.text('Generando el resumen del día…'), findsOneWidget);
        // El resto del Home sigue disponible: la generación no lo bloquea.
        expect(find.text('Calendario'), findsOneWidget);
        expect(find.byType(EmergencyTile), findsOneWidget);

        // El pedido nunca resuelve: se desmonta el árbol y se dejan correr los
        // temporizadores pendientes (spinner, autoDispose del provider).
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
      });

      testWidgets('al resolver muestra el resumen acotado y su hora', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(asignaciones: [_asignacionDesde(_testDependiente)]),
        );
        await _settleAnimations(tester);

        expect(find.text('Alicia tuvo una jornada tranquila.'), findsOneWidget);
        expect(find.text('09:05'), findsOneWidget);
        expect(find.text('Ver resumen completo'), findsOneWidget);
      });

      testWidgets('sin datos del día muestra el estado vacío', (tester) async {
        await tester.pumpWidget(
          _wrap(
            asignaciones: [_asignacionDesde(_testDependiente)],
            summaryRepository: _FakeSummaryRepository.conResumen(
              const ResumenInteligente(tieneDatos: false),
            ),
          ),
        );
        await _settleAnimations(tester);

        expect(
          find.textContaining('Nada para resumir todavía'),
          findsOneWidget,
        );
      });

      testWidgets('sin persona de contexto invita a elegir una', (
        tester,
      ) async {
        // La persona propia siempre es seleccionable, así que este estado sólo
        // aparece si no hay ninguna opción de contexto.
        await tester.pumpWidget(
          _wrap(
            asignaciones: [],
            personasOverride: personasSeleccionablesProvider.overrideWith(
              (ref) async => <PersonaContextOption>[],
            ),
          ),
        );
        await _settleAnimations(tester);
        // La cadena persona -> resumen encadena varios futures.
        await tester.pump();
        await tester.pump();

        expect(
          find.text('Elegí una persona a cargo para ver su resumen del día.'),
          findsOneWidget,
        );
      });

      testWidgets('si falla ofrece reintentar sin romper el resto del Home', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            asignaciones: [_asignacionDesde(_testDependiente)],
            summaryRepository: _FakeSummaryRepository.queFalla(),
          ),
        );
        await _settleAnimations(tester);

        expect(
          find.text('No pudimos generar el resumen ahora.'),
          findsOneWidget,
        );
        expect(find.text('Reintentar'), findsOneWidget);
        // El error queda contenido en la card: sin snackbars ni banners.
        expect(find.byType(SnackBar), findsNothing);
        expect(find.text('Calendario'), findsOneWidget);
        expect(find.byType(EmergencyTile), findsOneWidget);
      });
    });
  });
}
