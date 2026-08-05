import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/notifications/notifications.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/fake_notification_scheduler.dart';
import '../../../_fakes/fake_push_messaging_service.dart';

/// Mensaje equivalente al que envía el backend para una emergencia.
PushMessage _mensajeEmergencia({
  String? emergenciaId = '7',
  String? personaId = '12',
}) => PushMessage(
  titulo: 'Emergencia',
  cuerpo: 'Esteban C. activó una alerta de emergencia para Maria G.',
  datos: {
    'tipo': TiposPushConst.emergencia,
    'emergenciaId': ?emergenciaId,
    'personaId': ?personaId,
  },
);

void main() {
  group('pushForegroundProvider', () {
    test('renderiza la emergencia en el canal de emergencias', () async {
      final push = FakePushMessagingService();
      final scheduler = FakeNotificationScheduler();
      final container = ProviderContainer(
        overrides: [
          pushMessagingServiceProvider.overrideWithValue(push),
          notificationSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(push.dispose);

      container.read(pushForegroundProvider);
      push.emitirMensaje(_mensajeEmergencia());
      await pumpEventQueue();

      // El id se deriva de la emergencia para no duplicar el aviso.
      expect(scheduler.shown, [7]);
      expect(scheduler.shownChannels, [NotificationChannel.emergencias]);
      expect(scheduler.shownTitles, ['Emergencia']);
    });

    test('el aviso lleva el payload tipado, no un id suelto', () async {
      final push = FakePushMessagingService();
      final scheduler = FakeNotificationScheduler();
      final container = ProviderContainer(
        overrides: [
          pushMessagingServiceProvider.overrideWithValue(push),
          notificationSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(push.dispose);
      addTearDown(scheduler.dispose);

      container.read(pushForegroundProvider);
      push.emitirMensaje(_mensajeEmergencia());
      await pumpEventQueue();

      // Un "12" pelado sería indistinguible de un evento de agenda 12.
      expect(scheduler.shownPayloads, ['${TiposPushConst.emergencia}:12']);
    });

    test('sin personaId el aviso va sin payload', () async {
      final push = FakePushMessagingService();
      final scheduler = FakeNotificationScheduler();
      final container = ProviderContainer(
        overrides: [
          pushMessagingServiceProvider.overrideWithValue(push),
          notificationSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(push.dispose);
      addTearDown(scheduler.dispose);

      container.read(pushForegroundProvider);
      push.emitirMensaje(_mensajeEmergencia(personaId: null));
      await pumpEventQueue();

      expect(scheduler.shownPayloads, [isNull]);
    });

    test('ignora los mensajes que no son de emergencia', () async {
      final push = FakePushMessagingService();
      final scheduler = FakeNotificationScheduler();
      final container = ProviderContainer(
        overrides: [
          pushMessagingServiceProvider.overrideWithValue(push),
          notificationSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(push.dispose);

      container.read(pushForegroundProvider);
      push.emitirMensaje(
        const PushMessage(titulo: 'Otra cosa', datos: {'tipo': 'AGENDA'}),
      );
      await pumpEventQueue();

      expect(scheduler.shown, isEmpty);
    });
  });

  group('pushDeepLinkProvider', () {
    test('sin sesión no cambia la persona de contexto ni navega', () async {
      // Cubre el cableado de ambas fuentes (app cerrada y background): sin
      // sesión el destino queda en espera, así que no se toca el router.
      final push = FakePushMessagingService(
        initialMessage: _mensajeEmergencia(),
      );
      final scheduler = FakeNotificationScheduler();
      final container = ProviderContainer(
        overrides: [
          pushMessagingServiceProvider.overrideWithValue(push),
          notificationSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(push.dispose);
      addTearDown(scheduler.dispose);

      container.read(pushDeepLinkProvider);
      push.emitirAperturaApp(_mensajeEmergencia(personaId: '99'));
      await pumpEventQueue();

      expect(
        container.read(personaVisualizacionSeleccionadaIdProvider),
        isNull,
      );
    });

    test('el tap en una notificación local no rompe ni navega sin sesión', () {
      // El tap en foreground llega por el scheduler, no por FCM: verifica que
      // esa cuarta fuente esté cableada al mismo coordinator.
      final push = FakePushMessagingService();
      final scheduler = FakeNotificationScheduler();
      final container = ProviderContainer(
        overrides: [
          pushMessagingServiceProvider.overrideWithValue(push),
          notificationSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(push.dispose);
      addTearDown(scheduler.dispose);

      container.read(pushDeepLinkProvider);

      expect(
        () => scheduler.emitirTap('${TiposPushConst.emergencia}:12'),
        returnsNormally,
      );
      expect(
        container.read(personaVisualizacionSeleccionadaIdProvider),
        isNull,
      );
    });

    test('descarta los taps con payload inválido', () {
      final push = FakePushMessagingService();
      final scheduler = FakeNotificationScheduler();
      final container = ProviderContainer(
        overrides: [
          pushMessagingServiceProvider.overrideWithValue(push),
          notificationSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(push.dispose);
      addTearDown(scheduler.dispose);

      container.read(pushDeepLinkProvider);

      // Un id suelto (el formato viejo) ya no se interpreta como nada.
      expect(() => scheduler.emitirTap('12'), returnsNormally);
      expect(
        container.read(personaVisualizacionSeleccionadaIdProvider),
        isNull,
      );
    });
  });

  group('EmergencyDeepLinkCoordinator', () {
    test('abre el contexto de la persona cuando hay sesión', () {
      final abiertos = <int>[];
      final coordinator = EmergencyDeepLinkCoordinator(
        haySesion: () => true,
        abrirContexto: abiertos.add,
      );

      coordinator.procesar(_mensajeEmergencia());

      expect(abiertos, [12]);
      expect(coordinator.personaIdPendiente, isNull);
    });

    test('sin sesión deja el destino pendiente y no navega', () {
      final abiertos = <int>[];
      final coordinator = EmergencyDeepLinkCoordinator(
        haySesion: () => false,
        abrirContexto: abiertos.add,
      );

      coordinator.procesar(_mensajeEmergencia());

      expect(abiertos, isEmpty);
      expect(coordinator.personaIdPendiente, 12);
    });

    test('aplica el pendiente al iniciar sesión, una sola vez', () {
      var haySesion = false;
      final abiertos = <int>[];
      final coordinator = EmergencyDeepLinkCoordinator(
        haySesion: () => haySesion,
        abrirContexto: abiertos.add,
      );

      // Arranque en frío desde la notificación: la app abre en el login.
      coordinator.procesar(_mensajeEmergencia());
      coordinator.reintentarPendiente();
      expect(abiertos, isEmpty);

      haySesion = true;
      coordinator.reintentarPendiente();
      coordinator.reintentarPendiente();

      expect(abiertos, [12]);
      expect(coordinator.personaIdPendiente, isNull);
    });

    test('ignora mensajes de otro tipo y sin personaId', () {
      final abiertos = <int>[];
      final coordinator = EmergencyDeepLinkCoordinator(
        haySesion: () => true,
        abrirContexto: abiertos.add,
      );

      coordinator.procesar(const PushMessage(datos: {'tipo': 'AGENDA'}));
      coordinator.procesar(_mensajeEmergencia(personaId: null));

      expect(abiertos, isEmpty);
      expect(coordinator.personaIdPendiente, isNull);
    });
  });
}
