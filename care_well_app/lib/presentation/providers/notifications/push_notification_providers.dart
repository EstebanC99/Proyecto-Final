import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/routers/app_router.dart';
import '../../../config/routers/app_routes.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/notifications/notifications.dart';
import '../auth/auth_providers.dart';
import '../di_providers.dart';
import '../shared/personas_providers.dart';

/// Decide qué hacer cuando el usuario abre la app desde una notificación de
/// emergencia.
///
/// No conoce Riverpod ni go_router: recibe la consulta de sesión y la acción de
/// navegación como colaboradores, así que su lógica es testeable en aislamiento.
///
/// Si el aviso llega sin sesión activa (arranque en frío desde la notificación,
/// donde la app abre en el login), guarda el destino y lo aplica recién cuando
/// hay sesión: de lo contrario el `redirect` del router lo descartaría.
class EmergencyDeepLinkCoordinator {
  EmergencyDeepLinkCoordinator({
    required bool Function() haySesion,
    required void Function(int personaId) abrirContexto,
  }) : _haySesion = haySesion,
       _abrirContexto = abrirContexto;

  final bool Function() _haySesion;
  final void Function(int personaId) _abrirContexto;

  int? _personaIdPendiente;

  /// Destino en espera de que haya sesión. Visible para tests.
  int? get personaIdPendiente => _personaIdPendiente;

  /// Procesa un mensaje push tocado por el usuario.
  void procesar(PushMessage message) {
    if (message.tipo != TiposPushConst.emergencia) return;

    final personaId = message.personaId;
    if (personaId == null) return;

    if (_haySesion()) {
      _abrirContexto(personaId);
    } else {
      _personaIdPendiente = personaId;
    }
  }

  /// Aplica el destino pendiente, si hay uno y ya existe sesión.
  void reintentarPendiente() {
    final personaId = _personaIdPendiente;
    if (personaId == null || !_haySesion()) return;
    _personaIdPendiente = null;
    _abrirContexto(personaId);
  }
}

/// Renderiza las emergencias que llegan con la app en primer plano.
///
/// Android no muestra notificaciones push mientras la app está visible: hay que
/// emitir una notificación local equivalente, en el canal de emergencias.
///
/// Debe mantenerse vivo con un `ref.watch` desde `CareWellApp`.
final pushForegroundProvider = Provider<void>((ref) {
  final subscription = ref.watch(pushMessagingServiceProvider).onMessage.listen(
    (message) {
      if (message.tipo != TiposPushConst.emergencia) return;

      // Un id estable por emergencia evita duplicar el aviso; si el payload
      // no lo trae, se cae a un id derivado del instante de recepción.
      // La máscara garantiza un entero positivo, como exige Android.
      final notificationId =
          (message.emergenciaId ?? DateTime.now().millisecondsSinceEpoch) &
          0x7fffffff;

      ref
          .read(notificationSchedulerProvider)
          .showImmediateNotification(
            notificationId: notificationId,
            titulo: message.titulo ?? 'Emergencia',
            cuerpo: message.cuerpo ?? '',
            // Tipado: un id pelado no permitiría distinguir esta notificación
            // de la de un evento de agenda cuando se rutee el tap.
            payload: message.personaId == null
                ? null
                : NotificationPayload(
                    tipo: TiposPushConst.emergencia,
                    id: message.personaId!,
                  ).encode(),
            canal: NotificationChannel.emergencias,
          );
    },
  );

  ref.onDispose(subscription.cancel);
});

/// Abre la persona de contexto correcta cuando el usuario toca la notificación
/// de una emergencia, venga de background, de la app cerrada o de la
/// notificación local que se emite en foreground.
///
/// Las tres fuentes convergen en el mismo [EmergencyDeepLinkCoordinator], para
/// que la lógica de sesión pendiente no se duplique.
///
/// Debe mantenerse vivo con un `ref.watch` desde `CareWellApp`.
final pushDeepLinkProvider = Provider<void>((ref) {
  final coordinator = EmergencyDeepLinkCoordinator(
    haySesion: () => ref.read(authStateProvider).value != null,
    abrirContexto: (personaId) {
      ref.read(personaVisualizacionSeleccionadaIdProvider.notifier).state =
          personaId;
      ref.read(goRouterProvider).goNamed(AppRoutes.homeName);
    },
  );

  final service = ref.watch(pushMessagingServiceProvider);

  // App en background: el usuario tocó la notificación.
  final subscription = service.onMessageOpenedApp.listen(coordinator.procesar);
  ref.onDispose(subscription.cancel);

  // App cerrada: la notificación fue la que la abrió.
  service.getInitialMessage().then((message) {
    if (message != null) coordinator.procesar(message);
  });

  // App en foreground: el aviso lo renderizó pushForegroundProvider como
  // notificación local, así que el tap llega por el scheduler y no por FCM.
  final scheduler = ref.read(notificationSchedulerProvider);

  final tapSubscription = scheduler.onNotificationTap.listen((payload) {
    coordinator.procesar(_aPushMessage(payload));
  });
  ref.onDispose(tapSubscription.cancel);

  // App cerrada: la notificación LOCAL fue la que la abrió.
  scheduler.getLaunchPayload().then((payload) {
    if (payload != null) coordinator.procesar(_aPushMessage(payload));
  });

  // Al iniciar sesión se aplica el destino que quedó pendiente.
  ref.listen(authStateProvider, (_, _) => coordinator.reintentarPendiente());
});

/// Adapta el payload de una notificación local al mensaje que entiende el
/// coordinator, para que ambos orígenes compartan la misma decisión.
///
/// El coordinator descarta los tipos que no son de emergencia, así que no hace
/// falta filtrar acá.
PushMessage _aPushMessage(NotificationPayload payload) {
  return PushMessage(
    datos: {'tipo': payload.tipo, 'personaId': payload.id.toString()},
  );
}
