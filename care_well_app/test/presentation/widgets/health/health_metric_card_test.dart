import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap({
  String label = 'Hábitos de vida',
  String? prefix,
  String? value,
  String? suffix,
  HealthMetricCardLayout layout = HealthMetricCardLayout.grid,
  VoidCallback? onTap,
}) {
  return MaterialApp(
    theme: AppTheme().light,
    home: Scaffold(
      body: HealthMetricCard(
        icon: Icons.self_improvement,
        accentColor: const Color(0xFFEA580C),
        containerColor: const Color(0xFFFFEDD5),
        label: label,
        metricPrefix: prefix,
        metricValue: value,
        metricSuffix: suffix,
        layout: layout,
        onTap: onTap ?? () {},
      ),
    ),
  );
}

/// Texto plano de la línea de métrica (el `Text.rich` que no es el título).
String _metricaDe(WidgetTester tester, String label) {
  final textos = tester.widgetList<Text>(find.byType(Text));
  return textos
      .map((t) => t.textSpan?.toPlainText() ?? t.data ?? '')
      .firstWhere((texto) => texto != label, orElse: () => '');
}

void main() {
  group('HealthMetricCard', () {
    testWidgets('layout grid: ícono, label y métrica en columna', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(value: '2 de 5', suffix: ' completados hoy'),
      );

      expect(find.byIcon(Icons.self_improvement), findsOneWidget);
      expect(find.text('Hábitos de vida'), findsOneWidget);
      expect(_metricaDe(tester, 'Hábitos de vida'), '2 de 5 completados hoy');
      // El chevron es propio del layout wide.
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('layout wide: agrega el chevron', (tester) async {
      await tester.pumpWidget(
        _wrap(
          label: 'Eventos de salud',
          prefix: 'Último: ',
          value: 'hace 3 días',
          suffix: ' · Dolor de garganta',
          layout: HealthMetricCardLayout.wide,
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(
        _metricaDe(tester, 'Eventos de salud'),
        'Último: hace 3 días · Dolor de garganta',
      );
    });

    testWidgets('sin valor no dibuja el prefijo, solo el copy de vacío', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          label: 'Estado de ánimo',
          prefix: 'Hoy: ',
          suffix: 'Sin registro hoy',
        ),
      );

      expect(_metricaDe(tester, 'Estado de ánimo'), 'Sin registro hoy');
    });

    testWidgets('sin métrica la línea queda vacía', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(_metricaDe(tester, 'Hábitos de vida'), '');
    });

    testWidgets('el tap dispara onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(onTap: () => taps++));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hábitos de vida'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });
  });
}
