import 'package:care_well_app/presentation/widgets/settings/about_carewell_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wrapper mínimo: el diálogo es presentación pura, no necesita `ProviderScope`
/// ni mocks de `package_info_plus`.
///
/// El `MaterialApp` no registra los delegates de localización, así que los
/// botones que aporta el framework ("Ver licencias" / "Cerrar") salen en inglés.
/// Por eso los casos sólo verifican el contenido propio del diálogo.
Widget _wrap({String version = '1.2.0'}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (ctx) => TextButton(
          onPressed: () => mostrarAcercaDeCareWell(ctx, version: version),
          child: const Text('abrir'),
        ),
      ),
    ),
  );
}

Future<void> _abrirDialogo(WidgetTester tester) async {
  await tester.pumpWidget(_wrap());
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

void main() {
  group('mostrarAcercaDeCareWell', () {
    testWidgets('muestra nombre, versión y logo de la app', (tester) async {
      await _abrirDialogo(tester);

      expect(find.byType(AboutDialog), findsOneWidget);
      expect(find.text('CareWell'), findsOneWidget);
      expect(find.text('Versión 1.2.0'), findsOneWidget);

      final logo = tester.widget<Image>(
        find.descendant(
          of: find.byType(AboutDialog),
          matching: find.byType(Image),
        ),
      );
      expect(
        (logo.image as AssetImage).assetName,
        'assets/images/carewell-logo.png',
      );
    });

    testWidgets(
      'muestra el contenido propio: descripción, contacto y legalese',
      (tester) async {
        await _abrirDialogo(tester);

        expect(
          find.textContaining('centraliza la información de la persona'),
          findsOneWidget,
        );
        expect(
          find.text('Contacto: carewell.project.team@gmail.com'),
          findsOneWidget,
        );
        expect(find.text('© Bubisoft'), findsOneWidget);
      },
    );

    testWidgets('refleja la versión que recibe por parámetro', (tester) async {
      await tester.pumpWidget(_wrap(version: '9.9.9'));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Versión 9.9.9'), findsOneWidget);
      expect(find.text('Versión 1.2.0'), findsNothing);
    });

    testWidgets('se cierra al tocar fuera del diálogo', (tester) async {
      await _abrirDialogo(tester);

      // Esquina superior izquierda: barrier, fuera del contenido del diálogo.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.byType(AboutDialog), findsNothing);
    });
  });
}
