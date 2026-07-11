import 'dart:async';
import 'dart:typed_data';

import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/widgets/shared/avatar.dart';
import 'package:care_well_app/presentation/widgets/shared/persona_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(home: Scaffold(body: child)),
);

/// PNG 1x1 mínimo válido para instanciar un [MemoryImage] real.
final _pngBytes = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  group('PersonaAvatar', () {
    testWidgets('muestra la imagen cuando el provider resuelve con bytes', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PersonaAvatar(personaId: 1, nombre: 'Alicia', size: 44), [
          personaImagenProvider.overrideWith((ref, id) async => _pngBytes),
        ]),
      );
      await tester.pump(); // resuelve el Future

      final avatar = tester.widget<Avatar>(find.byType(Avatar));
      expect(avatar.imagen, isA<MemoryImage>());
      // No se muestra la inicial cuando hay imagen.
      expect(find.text('A'), findsNothing);
    });

    testWidgets('muestra la inicial cuando no hay imagen (404 → null)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PersonaAvatar(personaId: 2, nombre: 'Bruno', size: 44), [
          personaImagenProvider.overrideWith((ref, id) async => null),
        ]),
      );
      await tester.pump();

      final avatar = tester.widget<Avatar>(find.byType(Avatar));
      expect(avatar.imagen, isNull);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('mientras carga muestra la inicial (sin spinner)', (
      tester,
    ) async {
      final completer = Completer<Uint8List?>();
      await tester.pumpWidget(
        _wrap(const PersonaAvatar(personaId: 3, nombre: 'Carla', size: 44), [
          personaImagenProvider.overrideWith((ref, id) => completer.future),
        ]),
      );
      // Sin pump adicional: el Future sigue pendiente (estado loading).

      final avatar = tester.widget<Avatar>(find.byType(Avatar));
      expect(avatar.imagen, isNull);
      expect(find.text('C'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      completer.complete(null);
      await tester.pump();
    });
  });
}
