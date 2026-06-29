import 'package:care_well_app/config/constraints/business_rules.dart';
import 'package:care_well_app/presentation/widgets/shared/deleted_assignment_chip.dart';
import 'package:flutter_test/flutter_test.dart';

/// Construye una `fechaEliminacion` tal que falten aproximadamente
/// [diasRestantes] días para el vencimiento, con un colchón de 12 horas que
/// evita ambigüedad en el borde de truncamiento de `Duration.inDays`.
DateTime fechaConRestanteAprox(int diasRestantes) {
  final transcurridos = AppBusinessRules.diasGraciaReactivacion - diasRestantes;
  return DateTime.now().subtract(Duration(days: transcurridos, hours: -12));
}

void main() {
  group('reactivacionCountdownLabel', () {
    test('retorna "Eliminada" cuando la fecha es nula', () {
      expect(reactivacionCountdownLabel(null), 'Eliminada');
    });

    test(
      'cuenta casi el plazo completo cuando la asignación recién se eliminó',
      () {
        // Justo al eliminar quedan ~30 días; el truncamiento puede devolver 29
        // apenas transcurre tiempo entre las llamadas a DateTime.now().
        final ahora = DateTime.now();
        expect(
          reactivacionCountdownLabel(ahora),
          anyOf(
            'Vence en ${AppBusinessRules.diasGraciaReactivacion} días',
            'Vence en ${AppBusinessRules.diasGraciaReactivacion - 1} días',
          ),
        );
      },
    );

    test('muestra los días restantes a mitad de la ventana de gracia', () {
      expect(
        reactivacionCountdownLabel(fechaConRestanteAprox(15)),
        'Vence en 15 días',
      );
    });

    test('muestra "Vence en 1 día" cuando queda aproximadamente un día', () {
      expect(
        reactivacionCountdownLabel(fechaConRestanteAprox(1)),
        'Vence en 1 día',
      );
    });

    test('muestra "Vence hoy" cuando queda menos de un día', () {
      // fechaEliminacion ~ hace (30 días - 12h): restante ~12h -> inDays 0.
      final fecha = DateTime.now().subtract(
        Duration(days: AppBusinessRules.diasGraciaReactivacion, hours: -12),
      );
      expect(reactivacionCountdownLabel(fecha), 'Vence hoy');
    });

    test('muestra "Vencido" cuando el plazo de gracia ya expiró', () {
      final fecha = DateTime.now().subtract(
        Duration(days: AppBusinessRules.diasGraciaReactivacion + 1),
      );
      expect(reactivacionCountdownLabel(fecha), 'Vencido');
    });
  });
}
