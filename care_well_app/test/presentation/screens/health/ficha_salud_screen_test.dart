import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

final _persona = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _ficha = FichaSalud(
  id: 1,
  persona: _persona,
  factorSanguineo: '0+',
  obraSocial: 'PAMI',
  alergias: [FichaSaludAlergia(id: 1, nombre: 'Polen', reaccion: 'Estornudos')],
);

/// Overrides que respetan la dependencia real del provider de ficha: en
/// producción `fichaSaludProvider` espera a la persona de contexto, así que
/// nunca resuelve antes que ella. El override lo replica para no inventar un
/// orden de resolución que no puede darse.
List<Override> _overrides({
  FichaSalud? ficha,
  bool puedeVer = true,
  bool puedeEditar = true,
}) {
  return [
    personaVisualizacionSeleccionadaProvider.overrideWith(
      (ref) async => _persona,
    ),
    puedeVerSaludProvider.overrideWith((ref) async => puedeVer),
    puedeAdministrarFichaSaludProvider.overrideWith((ref) async => puedeEditar),
    fichaSaludProvider.overrideWith((ref) async {
      await ref.watch(personaVisualizacionSeleccionadaProvider.future);
      return ficha;
    }),
  ];
}

Widget _wrap({
  FichaSalud? ficha,
  bool puedeVer = true,
  bool puedeEditar = true,
}) {
  return ProviderScope(
    overrides: _overrides(
      ficha: ficha,
      puedeVer: puedeVer,
      puedeEditar: puedeEditar,
    ),
    child: const MaterialApp(home: FichaSaludScreen()),
  );
}

void main() {
  group('FichaSaludScreen', () {
    testWidgets('siembra el formulario cuando la ficha resuelve durante la '
        'pantalla', (tester) async {
      await tester.pumpWidget(_wrap(ficha: _ficha));
      await tester.pumpAndSettle();

      expect(find.byType(BloodTypeChipGrid), findsOneWidget);
      expect(find.text('PAMI'), findsOneWidget);
    });

    // Regresión: el hub de Salud observa `fichaSaludProvider` para sus chips,
    // así que al entrar acá la ficha suele estar YA resuelta. Sin transición de
    // estado el `ref.listen` no dispara y el formulario quedaba en skeleton.
    testWidgets('siembra el formulario aunque la ficha ya venga resuelta', (
      tester,
    ) async {
      final container = ProviderContainer(overrides: _overrides(ficha: _ficha));
      addTearDown(container.dispose);

      // Alguien más (el hub) ya resolvió la ficha y la persona de contexto.
      await container.read(personaVisualizacionSeleccionadaProvider.future);
      await container.read(fichaSaludProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: FichaSaludScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BloodTypeChipGrid), findsOneWidget);
      expect(find.text('PAMI'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('sin ficha previa siembra un formulario vacío', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byType(BloodTypeChipGrid), findsOneWidget);
      expect(find.text('PAMI'), findsNothing);
    });

    testWidgets('sin permiso no muestra el formulario', (tester) async {
      await tester.pumpWidget(_wrap(ficha: _ficha, puedeVer: false));
      await tester.pumpAndSettle();

      expect(find.byType(BloodTypeChipGrid), findsNothing);
    });
  });
}
