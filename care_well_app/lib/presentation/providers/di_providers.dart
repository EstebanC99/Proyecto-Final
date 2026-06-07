import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/datasources/datasources.dart';
import '../../domain/notifications/notifications.dart';
import '../../domain/repositories/repositories.dart';
import '../../infrastructure/datasources/datasources.dart';
import '../../infrastructure/notifications/notifications.dart';
import '../../infrastructure/repositories/repositories.dart';

final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => LocalNotificationScheduler(),
);

final authDatasourceProvider = Provider<AuthDatasource>(
  (ref) => DemoAuthDatasource(),
);

final personaDatasourceProvider = Provider<PersonaDatasource>(
  (ref) => DemoPersonaDatasource(),
);

final careTeamDatasourceProvider = Provider<CareTeamDatasource>(
  (ref) => DemoCareTeamDatasource(),
);

final agendaDatasourceProvider = Provider<AgendaDatasource>(
  (ref) => DemoAgendaDatasource(),
);

final healthDatasourceProvider = Provider<HealthDatasource>(
  (ref) => DemoHealthDatasource(),
);

final emergencyDatasourceProvider = Provider<EmergencyDatasource>(
  (ref) => DemoEmergencyDatasource(),
);

final settingsDatasourceProvider = Provider<SettingsDatasource>(
  (ref) => DemoSettingsDatasource(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authDatasourceProvider)),
);

final personaRepositoryProvider = Provider<PersonaRepository>(
  (ref) => PersonaRepositoryImpl(ref.watch(personaDatasourceProvider)),
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

final emergencyRepositoryProvider = Provider<EmergencyRepository>(
  (ref) => EmergencyRepositoryImpl(ref.watch(emergencyDatasourceProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(settingsDatasourceProvider)),
);
