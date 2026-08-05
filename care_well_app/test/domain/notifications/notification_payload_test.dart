import 'package:care_well_app/domain/notifications/notification_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationPayload', () {
    test('encode serializa como "<tipo>:<id>"', () {
      const payload = NotificationPayload(tipo: 'EMERGENCIA', id: 12);

      expect(payload.encode(), 'EMERGENCIA:12');
    });

    test('decode recupera lo que produjo encode', () {
      const original = NotificationPayload(tipo: 'EMERGENCIA', id: 12);

      final recuperado = NotificationPayload.decode(original.encode());

      expect(recuperado?.tipo, 'EMERGENCIA');
      expect(recuperado?.id, 12);
    });

    test('decode devuelve null para textos con formato inválido', () {
      // Un id suelto es justamente el caso ambiguo que este tipo elimina.
      expect(NotificationPayload.decode(null), isNull);
      expect(NotificationPayload.decode(''), isNull);
      expect(NotificationPayload.decode('12'), isNull);
      expect(NotificationPayload.decode(':12'), isNull);
      expect(NotificationPayload.decode('emergencia:'), isNull);
      expect(NotificationPayload.decode('emergencia:abc'), isNull);
    });
  });
}
