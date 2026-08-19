import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

Persona _persona(int id, {DateTime? fechaNacimiento}) => Persona(
  id: id,
  nombre: 'Persona $id',
  apellido: 'Apellido',
  documento: '3000000$id',
  fechaNacimiento: fechaNacimiento ?? DateTime(1950, 1, 1),
);

final _usuarioLogueado = _persona(1);

AsignacionCuidado _asignacion({
  required int id,
  required Persona personaCuidada,
  required RolCuidado rol,
}) => AsignacionCuidado(
  id: id,
  personaCuidada: personaCuidada,
  colaborador: _usuarioLogueado,
  rol: rol,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 1),
);

/// Auth repository mínimo: solo se usa para construir el [AuthNotifier] cuyo
/// estado se fija a mano en cada test.
class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Contenedor con la sesión y las asignaciones activas ya resueltas.
///
/// Se overridean los providers de asignaciones activas (no el repositorio) para
/// no reimplementar en el test el filtrado por rol y estado.
ProviderContainer _contenedor({
  List<AsignacionCuidado> comoResponsable = const [],
  List<AsignacionCuidado> comoCuidador = const [],
  Usuario? usuario,
}) {
  final container = ProviderContainer(
    overrides: [
      asignacionesActivasComoResponsableProvider.overrideWith(
        (ref) async => comoResponsable,
      ),
      asignacionesActivasComoCuidadorProvider.overrideWith(
        (ref) async => comoCuidador,
      ),
      authStateProvider.overrideWith((ref) {
        final notifier = AuthNotifier(_FakeAuthRepository());
        notifier.state = AsyncValue.data(usuario);
        return notifier;
      }),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Usuario _usuarioConNacimiento(DateTime fechaNacimiento) => Usuario(
  id: 101,
  persona: _persona(1, fechaNacimiento: fechaNacimiento),
  contrasena: '12345678',
  estado: estadoUsuarioActivo,
);

void main() {
  group('rolEnSistemaProvider', () {
    test('sin asignaciones activas no resuelve ningún rol', () async {
      final container = _contenedor();

      expect(await container.read(rolEnSistemaProvider.future), isNull);
    });

    test('con asignaciones como responsable resuelve Responsable', () async {
      final container = _contenedor(
        comoResponsable: [
          _asignacion(
            id: 1,
            personaCuidada: _persona(2),
            rol: rolCuidadoResponsable,
          ),
        ],
      );

      expect(
        await container.read(rolEnSistemaProvider.future),
        RolEnSistema.responsable,
      );
    });

    test('solo con asignaciones como cuidador resuelve Cuidador', () async {
      final container = _contenedor(
        comoCuidador: [
          _asignacion(
            id: 2,
            personaCuidada: _persona(3),
            rol: rolCuidadoCuidador,
          ),
        ],
      );

      expect(
        await container.read(rolEnSistemaProvider.future),
        RolEnSistema.cuidador,
      );
    });

    test('responsable prevalece sobre cuidador', () async {
      final container = _contenedor(
        comoResponsable: [
          _asignacion(
            id: 1,
            personaCuidada: _persona(2),
            rol: rolCuidadoResponsable,
          ),
        ],
        comoCuidador: [
          _asignacion(
            id: 2,
            personaCuidada: _persona(3),
            rol: rolCuidadoCuidador,
          ),
        ],
      );

      expect(
        await container.read(rolEnSistemaProvider.future),
        RolEnSistema.responsable,
      );
    });

    test('la etiqueta del rol es la que se muestra en la interfaz', () {
      expect(RolEnSistema.responsable.etiqueta, 'Responsable');
      expect(RolEnSistema.cuidador.etiqueta, 'Cuidador');
    });
  });

  group('statsPerfilProvider', () {
    test('sin sesión devuelve casillas en cero y sin edad', () async {
      final container = _contenedor();

      final stats = await container.read(statsPerfilProvider.future);
      expect(stats.aCargo, 0);
      expect(stats.colaboro, 0);
      expect(stats.edad, isNull);
    });

    test('cuenta personas distintas, no asignaciones', () async {
      final alicia = _persona(2);
      final carlos = _persona(3);
      final container = _contenedor(
        usuario: _usuarioConNacimiento(DateTime(1990, 1, 1)),
        comoResponsable: [
          _asignacion(
            id: 1,
            personaCuidada: alicia,
            rol: rolCuidadoResponsable,
          ),
          // Segunda asignación sobre la MISMA persona: no debe sumar.
          _asignacion(
            id: 2,
            personaCuidada: alicia,
            rol: rolCuidadoResponsable,
          ),
          _asignacion(
            id: 3,
            personaCuidada: carlos,
            rol: rolCuidadoResponsable,
          ),
        ],
        comoCuidador: [
          _asignacion(id: 4, personaCuidada: carlos, rol: rolCuidadoCuidador),
        ],
      );

      final stats = await container.read(statsPerfilProvider.future);
      expect(stats.aCargo, 2);
      expect(stats.colaboro, 1);
    });

    test('sin asignaciones mantiene las tres casillas en cero', () async {
      final container = _contenedor(
        usuario: _usuarioConNacimiento(DateTime(1990, 1, 1)),
      );

      final stats = await container.read(statsPerfilProvider.future);
      expect(stats.aCargo, 0);
      expect(stats.colaboro, 0);
    });

    // Las fechas se derivan de DateTime.now() para no fijar una fecha absoluta
    // (no hay clockProvider en el proyecto). El año se toma del día objetivo y
    // no del de hoy, para que los casos sigan valiendo en el cambio de año.
    test('la edad descuenta el año si todavía no cumplió', () async {
      final manana = DateTime.now().add(const Duration(days: 1));
      final container = _contenedor(
        usuario: _usuarioConNacimiento(
          DateTime(manana.year - 40, manana.month, manana.day),
        ),
      );

      final stats = await container.read(statsPerfilProvider.future);
      expect(stats.edad, 39);
    });

    test('la edad cuenta el año si ya cumplió', () async {
      final ayer = DateTime.now().subtract(const Duration(days: 1));
      final container = _contenedor(
        usuario: _usuarioConNacimiento(
          DateTime(ayer.year - 40, ayer.month, ayer.day),
        ),
      );

      final stats = await container.read(statsPerfilProvider.future);
      expect(stats.edad, 40);
    });

    test('el día exacto del cumpleaños ya cuenta el año', () async {
      final ahora = DateTime.now();
      // Un 29/02 el aniversario exacto no existe en un año no bisiesto
      // (DateTime lo normalizaría al 1/3, adelantando el cumpleaños): ese único
      // día se toma el 28/02 como fecha de nacimiento, que a esta altura del
      // año ya está cumplido igual.
      final hoy = (ahora.month == DateTime.february && ahora.day == 29)
          ? ahora.subtract(const Duration(days: 1))
          : ahora;
      final container = _contenedor(
        usuario: _usuarioConNacimiento(
          DateTime(hoy.year - 40, hoy.month, hoy.day),
        ),
      );

      final stats = await container.read(statsPerfilProvider.future);
      expect(stats.edad, 40);
    });
  });
}
