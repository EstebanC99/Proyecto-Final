import 'package:care_well_app/infrastructure/notifications/notifications.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_fakes/fake_dispositivo_repository.dart';

void main() {
  group('pushMessagingServiceProvider', () {
    test('sin SDK disponible resuelve al servicio nulo', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // El default de pushDisponibleProvider es false: si esto se rompiera, los
      // tests intentarían construir el servicio de Firebase y explotarían.
      expect(
        container.read(pushMessagingServiceProvider),
        isA<NullPushMessagingService>(),
      );
    });

    test('el servicio nulo no registra ningún dispositivo', () async {
      final dispositivos = FakeDispositivoRepository();
      final container = ProviderContainer(
        overrides: [
          dispositivoRepositoryProvider.overrideWithValue(dispositivos),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(pushTokenSynchronizerProvider)
          .registrarDispositivo();

      // Sin token no hay nada que registrar: la app funciona igual, sin push.
      expect(dispositivos.registrados, isEmpty);
    });
  });
}
