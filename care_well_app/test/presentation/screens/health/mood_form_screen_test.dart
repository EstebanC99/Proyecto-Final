import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _RegistrarAnimo =
    Future<void> Function({required int estadoAnimoId, String? observaciones});

Widget _wrap({_RegistrarAnimo? onRegistrar}) {
  return ProviderScope(
    overrides: [
      // Sin persona de contexto: evita renderizar el ContextSelector.
      healthPersonaContextProvider.overrideWith((ref) async => null),
      registrarAnimoProvider.overrideWithValue(
        onRegistrar ?? (({required estadoAnimoId, observaciones}) async {}),
      ),
    ],
    child: const MaterialApp(home: MoodFormScreen()),
  );
}

void main() {
  group('MoodFormScreen', () {
    testWidgets(
      'el botón Registrar arranca deshabilitado y muestra el texto guía',
      (tester) async {
        await tester.pumpWidget(_wrap());
        await tester.pumpAndSettle();

        expect(
          find.text('Tocá las flechas para elegir un estado y confirmar.'),
          findsOneWidget,
        );
        expect(find.byType(FilledButton), findsNothing);
        final boton = tester.widget<OutlinedButton>(
          find.byType(OutlinedButton),
        );
        expect(boton.onPressed, isNull);
      },
    );

    testWidgets(
      'tras interactuar con el dial el botón se habilita y registra el nivel',
      (tester) async {
        int? registrado;
        await tester.pumpWidget(
          _wrap(
            onRegistrar: ({required estadoAnimoId, observaciones}) async {
              registrado = estadoAnimoId;
            },
          ),
        );
        await tester.pumpAndSettle();

        // Default regular(3); mejorar una vez → bien(2).
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        // El botón pasó a filled y quedó habilitado.
        expect(find.byType(OutlinedButton), findsNothing);
        final filled = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(filled.onPressed, isNotNull);

        await tester.ensureVisible(find.byType(FilledButton));
        await tester.tap(find.byType(FilledButton));
        // Deja que el registro (fake) resuelva y drena los timers del
        // SnackBar de éxito para evitar timers pendientes en el teardown.
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));

        expect(registrado, EstadosAnimoConst.bien);
      },
    );
  });
}
