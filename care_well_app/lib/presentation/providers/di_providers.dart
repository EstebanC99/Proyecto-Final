import 'package:care_well_app/domain/repositories/tipo_evento_repository.dart';
import 'package:care_well_app/infrastructure/repositories/tipo_evento_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../../domain/datasources/datasources.dart';
import '../../domain/notifications/notifications.dart';
import '../../domain/repositories/repositories.dart';
import '../../infrastructure/datasources/datasources.dart';
import '../../infrastructure/http/http_configs.dart';
import '../../infrastructure/notifications/notifications.dart';
import '../../infrastructure/repositories/repositories.dart';
import '../../infrastructure/storage/token_storage.dart';

/// Activa el modo demo (datasources mock, sin backend).
///
/// Por defecto [true] para que la app funcione sin servidor.
/// Cambiar a [false] inyectando el valor via `--dart-define=USE_DEMO=false`
/// para conectarse al backend real.
const bool _useDemo = bool.fromEnvironment('USE_DEMO', defaultValue: true);

//region Infraestructura HTTP Providers

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(ref.watch(flutterSecureStorageProvider)),
);

final dioClientProvider = Provider<Dio>(
  (ref) => createDioClient(ref.watch(tokenStorageProvider)),
);

//endregion

//region Notificaciones Providers

final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => LocalNotificationScheduler(),
);

//endregion

//region Datasources Providers

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  if (_useDemo) return DemoAuthDatasource();
  return ApiAuthDatasource(
    ref.watch(dioClientProvider),
    ref.watch(tokenStorageProvider),
  );
});

final personaDatasourceProvider = Provider<PersonaDatasource>((ref) {
  if (_useDemo) return DemoPersonaDatasource();
  return ApiPersonaDatasource(ref.watch(dioClientProvider));
});

final asignacionCuidadoDatasourceProvider =
    Provider<AsignacionCuidadoDatasource>((ref) {
      return ApiAsignacionCuidadoDatasource(ref.watch(dioClientProvider));
    });

final careTeamDatasourceProvider = Provider<CareTeamDatasource>(
  (ref) => DemoCareTeamDatasource(),
);

final agendaDatasourceProvider = Provider<AgendaDatasource>(
  (ref) => ApiAgendaDatasource(ref.watch(dioClientProvider)),
);

final healthDatasourceProvider = Provider<HealthDatasource>(
  (ref) => DemoHealthDatasource(),
);

final eventoSaludDatasourceProvider = Provider<EventoSaludDatasource>((ref) {
  if (_useDemo) return DemoEventoSaludDatasource();
  return ApiEventoSaludDatasource(ref.watch(dioClientProvider));
});

final habitoVidaDatasourceProvider = Provider<HabitoVidaDatasource>(
  (ref) => ApiHabitoVidaDatasource(ref.watch(dioClientProvider)),
);

final estadoAnimoDatasourceProvider = Provider<EstadoAnimoDatasource>(
  (ref) => ApiEstadoAnimoDatasource(ref.watch(dioClientProvider)),
);

final emergencyDatasourceProvider = Provider<EmergencyDatasource>(
  (ref) => DemoEmergencyDatasource(),
);

final settingsDatasourceProvider = Provider<SettingsDatasource>(
  (ref) => DemoSettingsDatasource(),
);

final tipoEventoDatasourceProvider = Provider<TipoEventoDatasource>(
  (ref) => ApiTipoEventoDatasource(ref.watch(dioClientProvider)),
);

//endregion

//region Repositories Providers

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authDatasourceProvider)),
);

final personaRepositoryProvider = Provider<PersonaRepository>(
  (ref) => PersonaRepositoryImpl(ref.watch(personaDatasourceProvider)),
);

final asignacionCuidadoRepositoryProvider =
    Provider<AsignacionCuidadoRepository>(
      (ref) => AsignacionCuidadoRepositoryImpl(
        ref.watch(asignacionCuidadoDatasourceProvider),
      ),
    );

final careTeamRepositoryProvider = Provider<CareTeamRepository>(
  (ref) => CareTeamRepositoryImpl(ref.watch(careTeamDatasourceProvider)),
);

final agendaRepositoryProvider = Provider<AgendaRepository>(
  (ref) => AgendaRepositoryImpl(ref.watch(agendaDatasourceProvider)),
);

final healthRepositoryProvider = Provider<HealthRepository>(
  (ref) => HealthRepositoryImpl(ref.watch(healthDatasourceProvider)),
);

final eventoSaludRepositoryProvider = Provider<EventoSaludRepository>(
  (ref) => EventoSaludRepositoryImpl(ref.watch(eventoSaludDatasourceProvider)),
);

final habitoVidaRepositoryProvider = Provider<HabitoVidaRepository>(
  (ref) => HabitoVidaRepositoryImpl(ref.watch(habitoVidaDatasourceProvider)),
);

final estadoAnimoRepositoryProvider = Provider<EstadoAnimoRepository>(
  (ref) => EstadoAnimoRepositoryImpl(ref.watch(estadoAnimoDatasourceProvider)),
);

final emergencyRepositoryProvider = Provider<EmergencyRepository>(
  (ref) => EmergencyRepositoryImpl(ref.watch(emergencyDatasourceProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(settingsDatasourceProvider)),
);

final tipoEventoRepositoryProvider = Provider<TipoEventoRepository>(
  (ref) => TipoEventoRepositoryImpl(ref.watch(tipoEventoDatasourceProvider)),
);

//endregion
