import 'package:care_well_app/infrastructure/notifications/local_notification_scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveScheduleMode', () {
    test('con permiso concedido programa en modo exacto', () {
      expect(
        resolveScheduleMode(true),
        AndroidScheduleMode.exactAllowWhileIdle,
      );
    });

    test('sin permiso degrada a modo inexacto', () {
      expect(
        resolveScheduleMode(false),
        AndroidScheduleMode.inexactAllowWhileIdle,
      );
    });

    test('ambos modos disparan con el dispositivo en Doze', () {
      // allowWhileIdle es innegociable en las dos ramas: un recordatorio de
      // medicación no puede quedar retenido hasta que el usuario desbloquee.
      for (final concedido in [true, false]) {
        expect(resolveScheduleMode(concedido).name, contains('AllowWhileIdle'));
      }
    });
  });
}
