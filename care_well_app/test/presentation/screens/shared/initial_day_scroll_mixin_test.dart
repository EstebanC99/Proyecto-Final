import 'package:care_well_app/presentation/screens/shared/initial_day_scroll_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget mínimo que expone [InitialDayScrollMixin] para poder probar la lógica
/// pura de [calcularDiaObjetivo] a través de una instancia real de `State`.
class _Host extends ConsumerStatefulWidget {
  const _Host({required GlobalKey<_HostState> stateKey}) : super(key: stateKey);

  @override
  ConsumerState<_Host> createState() => _HostState();
}

class _HostState extends ConsumerState<_Host> with InitialDayScrollMixin {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

void main() {
  late GlobalKey<_HostState> key;

  Future<_HostState> montar(WidgetTester tester) async {
    key = GlobalKey<_HostState>();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: _Host(stateKey: key)),
      ),
    );
    return key.currentState!;
  }

  group('calcularDiaObjetivo', () {
    final ahora = DateTime.now();
    final mesActual = DateTime(ahora.year, ahora.month, 1);
    final hoy = _dia(ahora);

    testWidgets('devuelve null cuando el mes no es el actual', (tester) async {
      final estado = await montar(tester);
      final otroMes = DateTime(ahora.year, ahora.month - 1, 1);
      final dias = [_dia(ahora.subtract(const Duration(days: 40)))];
      expect(estado.calcularDiaObjetivo(dias, otroMes), isNull);
    });

    testWidgets('devuelve null cuando no hay días', (tester) async {
      final estado = await montar(tester);
      expect(estado.calcularDiaObjetivo(const [], mesActual), isNull);
    });

    testWidgets('prioriza "hoy" cuando existe', (tester) async {
      final estado = await montar(tester);
      final dias = [
        hoy.subtract(const Duration(days: 3)),
        hoy,
        hoy.add(const Duration(days: 2)),
      ];
      expect(estado.calcularDiaObjetivo(dias, mesActual), hoy);
    });

    testWidgets('si hoy no tiene eventos va al próximo posterior', (
      tester,
    ) async {
      final estado = await montar(tester);
      final proximo = hoy.add(const Duration(days: 1));
      final dias = [
        hoy.subtract(const Duration(days: 5)),
        proximo,
        hoy.add(const Duration(days: 4)),
      ];
      expect(estado.calcularDiaObjetivo(dias, mesActual), proximo);
    });

    testWidgets('sin hoy ni posteriores va al último anterior', (tester) async {
      final estado = await montar(tester);
      final ultimoAnterior = hoy.subtract(const Duration(days: 1));
      final dias = [hoy.subtract(const Duration(days: 5)), ultimoAnterior];
      expect(estado.calcularDiaObjetivo(dias, mesActual), ultimoAnterior);
    });
  });
}
