import 'package:care_well_app/presentation/widgets/shared/password_strength_meter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

void main() {
  group('calcularFortaleza (función pura)', () {
    test(
      'string vacío no se llama directamente (password vacío → null en meter)',
      () {
        // La fortaleza solo se computa si password.isNotEmpty.
        // Verificamos la función auxiliar directamente.
        expect(calcularFortaleza('abc'), PasswordStrength.weak);
        expect(calcularFortaleza('abcdefgh'), PasswordStrength.medium);
        expect(calcularFortaleza('Abcdefg1'), PasswordStrength.strong);
      },
    );

    test('menos de 8 chars → débil', () {
      expect(calcularFortaleza('1234567'), PasswordStrength.weak);
    });

    test('8+ chars sin mayúscula ni número → media', () {
      expect(calcularFortaleza('abcdefgh'), PasswordStrength.medium);
    });

    test('8+ chars solo con número (sin mayúscula) → media', () {
      expect(calcularFortaleza('abcdefg1'), PasswordStrength.medium);
    });

    test('8+ chars con mayúscula y número → fuerte', () {
      expect(calcularFortaleza('Abcdefg1'), PasswordStrength.strong);
    });
  });

  group('PasswordStrengthMeter widget', () {
    testWidgets('muestra "Mínimo 8 caracteres" con password vacío', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PasswordStrengthMeter(password: '')));
      expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
    });

    testWidgets('muestra "Débil" con password corto', (tester) async {
      await tester.pumpWidget(
        _wrap(const PasswordStrengthMeter(password: '1234')),
      );
      expect(find.text('Débil'), findsOneWidget);
    });

    testWidgets(
      'muestra "Media" con password de 8+ chars sin mayúscula/número',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const PasswordStrengthMeter(password: 'abcdefgh')),
        );
        expect(find.text('Media'), findsOneWidget);
      },
    );

    testWidgets(
      'muestra "Fuerte" con password de 8+ chars con mayúscula y número',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const PasswordStrengthMeter(password: 'Abcdefg1')),
        );
        expect(find.text('Fuerte'), findsOneWidget);
      },
    );

    testWidgets('monta sin errores', (tester) async {
      await tester.pumpWidget(
        _wrap(const PasswordStrengthMeter(password: 'test')),
      );
      expect(find.byType(PasswordStrengthMeter), findsOneWidget);
    });
  });
}
